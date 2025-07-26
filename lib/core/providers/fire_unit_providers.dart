import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fire_unit.dart';
import '../models/user.dart';
import '../services/fire_unit_service.dart';
import 'auth_providers.dart';
import 'product_providers.dart';
import 'vehicle_providers.dart';
import 'checklist_providers.dart';
import 'movement_providers.dart';

// Provider para todas as unidades ativas
final fireUnitsProvider = StreamProvider<List<FireUnit>>((ref) {
  return FireUnitService.getActiveUnits();
});

// Provider para a unidade atualmente selecionada
final currentUnitProvider = StateProvider<FireUnit?>((ref) => null);

// Provider para unidades que o usuário tem acesso
final userUnitsProvider = FutureProvider<List<FireUnit>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  
  // Aguardar o usuário carregar usando when
  return await userAsync.when(
    data: (user) async {
      print('🔍 userUnitsProvider: Carregando unidades para usuário ${user?.email ?? "null"}');
      if (user == null) {
        print('❌ userUnitsProvider: Usuário não autenticado');
        return <FireUnit>[];
      }
      
      print('🔍 userUnitsProvider: isGlobalAdmin: ${user.isGlobalAdmin}');
      print('🔍 userUnitsProvider: unitIds: ${user.unitIds}');
      
      print('DEBUG: userUnitsProvider - user.isGlobalAdmin: ${user.isGlobalAdmin}');
      print('DEBUG: userUnitsProvider - user.unitIds: ${user.unitIds}');
      
      // Se é admin global, retorna todas as unidades disponíveis
      if (user.isGlobalAdmin) {
        try {
          print('🔍 userUnitsProvider - Usuário é admin global, buscando todas as unidades...');
          // Para admin global, sempre buscar diretamente do serviço para evitar cache
          final allUnits = await FireUnitService.getActiveUnits().first;
          print('🌐 userUnitsProvider: Admin global - ${allUnits.length} unidades encontradas');
          for (var unit in allUnits) {
            print('📋 userUnitsProvider: Unidade: ${unit.code} - ${unit.name}');
          }
          return allUnits;
        } catch (e) {
          print('❌ userUnitsProvider - Erro ao carregar unidades para admin global: $e');
          throw e;
        }
      }
      
      // Senão, retorna apenas as unidades que o usuário tem acesso
      if (user.unitIds.isEmpty) {
        print('⚠️ userUnitsProvider - user.unitIds is empty for ${user.email}');
        print('🔄 userUnitsProvider - Aguardando vinculação de unidades...');
        
        // Aguardar um pouco e tentar novamente (pode ser que a vinculação ainda esteja em processo)
        await Future.delayed(const Duration(seconds: 2));
        
        // Invalidar o provider do usuário para forçar reload
        ref.invalidate(currentUserProvider);
        
        // Verificar novamente após invalidação
        final updatedUserAsync = ref.read(currentUserProvider);
        if (updatedUserAsync.hasValue && updatedUserAsync.value != null) {
          final updatedUser = updatedUserAsync.value!;
          if (updatedUser.unitIds.isNotEmpty) {
            print('✅ userUnitsProvider - Unidades encontradas após reload: ${updatedUser.unitIds.length}');
            final units = await FireUnitService.getUnitsByIds(updatedUser.unitIds);
            return units;
          }
        }
        
        print('❌ userUnitsProvider - Usuário ainda sem unidades após reload');
        return <FireUnit>[];
      }
      
      try {
        final units = await FireUnitService.getUnitsByIds(user.unitIds);
        print('DEBUG: userUnitsProvider - loaded units: ${units.length}');
        for (var unit in units) {
          print('DEBUG: userUnitsProvider - unit: ${unit.code} - ${unit.name}');
        }
        return units;
      } catch (e) {
        print('DEBUG: userUnitsProvider - error loading units: $e');
        throw e;
      }
    },
    loading: () async {
      print('⏳ userUnitsProvider: Carregando...');
      return <FireUnit>[];
    },
    error: (error, stackTrace) async {
      print('❌ userUnitsProvider: Erro - $error');
      throw error;
    },
  );
});

// Provider para verificar se o usuário pode trocar de unidade
final canSwitchUnitsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.canSwitchUnits ?? false;
});

// Provider para obter unidade por ID
final unitByIdProvider = FutureProvider.family<FireUnit?, String>((ref, unitId) async {
  return await FireUnitService.getUnitById(unitId);
});

// Provider para estatísticas das unidades
final unitsStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return await FireUnitService.getUnitsStats();
});

// Notifier para gerenciar a seleção de unidade
class UnitSelectionNotifier extends StateNotifier<AsyncValue<FireUnit?>> {
  UnitSelectionNotifier(this.ref) : super(const AsyncValue.loading()) {
    // Escutar mudanças no currentUserProvider
    ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        _initializeCurrentUnit(next.value!);
      } else if (next.hasValue && next.value == null) {
        state = const AsyncValue.data(null);
      }
    });
    
    // Tentar inicializar imediatamente se o usuário já estiver disponível
    final userAsync = ref.read(currentUserProvider);
    if (userAsync.hasValue && userAsync.value != null) {
      _initializeCurrentUnit(userAsync.value!);
    }
  }

  final Ref ref;

  // Inicializar a unidade atual baseada no usuário
  Future<void> _initializeCurrentUnit(AppUser user) async {
    try {
      print('🔄 UnitSelectionNotifier: Inicializando unidade para ${user.email}');
      print('📋 UnitSelectionNotifier: isGlobalAdmin=${user.isGlobalAdmin}, unitIds=${user.unitIds.length}, currentUnitId=${user.currentUnitId}');

      FireUnit? currentUnit;

      // Se o usuário tem uma unidade atual definida, tentar carregá-la
      if (user.currentUnitId != null) {
        try {
          currentUnit = await FireUnitService.getUnitById(user.currentUnitId!);
          print('✅ UnitSelectionNotifier: Unidade atual carregada: ${currentUnit?.code}');
        } catch (e) {
          print('⚠️ UnitSelectionNotifier: Erro ao carregar unidade atual: $e');
          currentUnit = null;
        }
      }
      
      // Se não encontrou a unidade atual ou não está definida
      if (currentUnit == null) {
        if (user.isGlobalAdmin) {
          // Para admin global, pegar a primeira unidade disponível
          print('🔍 UnitSelectionNotifier: Admin global sem unidade, buscando primeira disponível...');
          final allUnits = await ref.read(fireUnitsProvider.future);
          if (allUnits.isNotEmpty) {
            currentUnit = allUnits.first;
            await _updateUserCurrentUnit(currentUnit.id);
            print('✅ UnitSelectionNotifier: Admin global configurado com unidade: ${currentUnit.code}');
          } else {
            print('❌ UnitSelectionNotifier: Nenhuma unidade disponível no sistema');
          }
        } else if (user.unitIds.isNotEmpty) {
          // Para usuário comum, pegar a primeira unidade das suas unidades
          print('🔍 UnitSelectionNotifier: Usuário comum sem unidade atual, buscando primeira das suas unidades...');
          final userUnits = await FireUnitService.getUnitsByIds(user.unitIds);
          if (userUnits.isNotEmpty) {
            currentUnit = userUnits.first;
            await _updateUserCurrentUnit(currentUnit.id);
            print('✅ UnitSelectionNotifier: Usuário configurado com unidade: ${currentUnit.code}');
          } else {
            print('❌ UnitSelectionNotifier: Usuário não tem acesso a nenhuma unidade válida');
          }
        } else {
          print('❌ UnitSelectionNotifier: Usuário sem unidades vinculadas');
        }
      }

      state = AsyncValue.data(currentUnit);
      
      // Atualizar o provider da unidade atual
      ref.read(currentUnitProvider.notifier).state = currentUnit;
      
      if (currentUnit != null) {
        print('🎯 UnitSelectionNotifier: Unidade final selecionada: ${currentUnit.code}');
      } else {
        print('⚠️ UnitSelectionNotifier: Nenhuma unidade foi selecionada');
      }
      
    } catch (error, stackTrace) {
      print('❌ UnitSelectionNotifier: Erro na inicialização: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Selecionar uma nova unidade
  Future<void> selectUnit(FireUnit unit) async {
    try {
      state = const AsyncValue.loading();
      
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verificar se o usuário tem acesso à unidade
      if (!user.hasAccessToUnit(unit.id)) {
        throw Exception('Usuário não tem acesso a esta unidade');
      }

      // Atualizar a unidade atual do usuário no Firestore
      await _updateUserCurrentUnit(unit.id);
      
      state = AsyncValue.data(unit);
      
      // Atualizar o provider da unidade atual
      ref.read(currentUnitProvider.notifier).state = unit;
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Atualizar a unidade atual do usuário no Firestore
  Future<void> _updateUserCurrentUnit(String unitId) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user != null) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.updateUserProfile({
        'currentUnitId': unitId,
      });
    }
  }

  // Limpar seleção de unidade
  void clearSelection() {
    state = const AsyncValue.data(null);
    ref.read(currentUnitProvider.notifier).state = null;
  }

  // Recarregar unidade atual
  Future<void> refresh() async {
    final userAsync = ref.read(currentUserProvider);
    if (userAsync.hasValue && userAsync.value != null) {
      await _initializeCurrentUnit(userAsync.value!);
    }
  }

  // Método para recarregar as unidades e a unidade atual
  void refreshUnits() {
    ref.invalidate(currentUserProvider);
    ref.invalidate(userUnitsProvider);
    ref.invalidate(currentUnitProvider);
  }
}

// Provider para o notifier de seleção de unidade
final unitSelectionProvider = StateNotifierProvider<UnitSelectionNotifier, AsyncValue<FireUnit?>>((ref) {
  return UnitSelectionNotifier(ref);
});

// Provider para verificar se uma unidade específica está selecionada
final isUnitSelectedProvider = Provider.family<bool, String>((ref, unitId) {
  final currentUnit = ref.watch(currentUnitProvider);
  return currentUnit?.id == unitId;
});

// Provider para filtrar dados por unidade atual
final currentUnitIdProvider = Provider<String?>((ref) {
  final currentUnit = ref.watch(currentUnitProvider);
  return currentUnit?.id;
});

// Provider para verificar se o usuário tem acesso à unidade atual
final hasCurrentUnitAccessProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  final currentUnit = ref.watch(currentUnitProvider);
  
  if (user == null || currentUnit == null) return false;
  
  return user.hasAccessToUnit(currentUnit.id);
});

// Provider para obter o nome da unidade atual
final currentUnitNameProvider = Provider<String>((ref) {
  final currentUnit = ref.watch(currentUnitProvider);
  return currentUnit?.name ?? 'Nenhuma unidade selecionada';
});

// Provider para obter o código da unidade atual
final currentUnitCodeProvider = Provider<String>((ref) {
  final currentUnit = ref.watch(currentUnitProvider);
  return currentUnit?.code ?? '';
});

// Provider que escuta mudanças na unidade atual e invalida caches relacionados
final unitChangeListenerProvider = Provider<void>((ref) {
  final currentUnitId = ref.watch(currentUnitIdProvider);
  
  // Quando a unidade muda, invalidar todos os providers que dependem da unidade
  ref.listen<String?>(currentUnitIdProvider, (previous, next) {
    if (previous != next && next != null) {
      // Invalidar providers de produtos
      ref.invalidate(productsStreamProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(filteredProductsProvider);
      ref.invalidate(lowStockProductsProvider);
      ref.invalidate(criticalStockProductsProvider);
      
      // Invalidar providers de veículos
      ref.invalidate(vehiclesStreamProvider);
      
      // Invalidar providers de checklists
      ref.invalidate(checklistsStreamProvider);
      ref.invalidate(checklistsByVehicleProvider);
      
      // Invalidar providers de movimentações
      ref.invalidate(recentMovementsProvider);
      ref.invalidate(userMovementsProvider);
      ref.invalidate(defaultRecentMovementsProvider);
      
      print('DEBUG: Unidade alterada de $previous para $next - Caches invalidados');
    }
  });
  
  return;
});