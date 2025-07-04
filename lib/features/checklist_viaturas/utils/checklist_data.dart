import 'package:flutter/material.dart';
import '../models/checklist_category.dart';
import '../models/checklist_item.dart';

class ChecklistData {
  static List<ChecklistCategory> getDefaultCategories() {
    return [
      ChecklistCategory(
        id: 'pneus_rodas',
        title: 'Pneus e Rodas',
        description: 'Verificação dos pneus e componentes das rodas',
        icon: Icons.tire_repair,
        items: [
          ChecklistItem(
            id: 'pneu_dianteiro_esquerdo',
            title: 'Pneu Dianteiro Esquerdo',
            description: 'Verificar estado, pressão e desgaste',
          ),
          ChecklistItem(
            id: 'pneu_dianteiro_direito',
            title: 'Pneu Dianteiro Direito',
            description: 'Verificar estado, pressão e desgaste',
          ),
          ChecklistItem(
            id: 'pneu_traseiro_esquerdo',
            title: 'Pneu Traseiro Esquerdo',
            description: 'Verificar estado, pressão e desgaste',
          ),
          ChecklistItem(
            id: 'pneu_traseiro_direito',
            title: 'Pneu Traseiro Direito',
            description: 'Verificar estado, pressão e desgaste',
          ),
          ChecklistItem(
            id: 'pneu_estepe',
            title: 'Pneu Estepe',
            description: 'Verificar estado e pressão do estepe',
          ),
          ChecklistItem(
            id: 'parafusos_rodas',
            title: 'Parafusos das Rodas',
            description: 'Verificar aperto e estado dos parafusos',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'motor_fluidos',
        title: 'Motor e Fluidos',
        description: 'Verificação do motor e níveis de fluidos',
        icon: Icons.build,
        items: [
          ChecklistItem(
            id: 'nivel_oleo_motor',
            title: 'Nível do Óleo do Motor',
            description: 'Verificar nível e qualidade do óleo',
          ),
          ChecklistItem(
            id: 'nivel_agua_radiador',
            title: 'Nível da Água do Radiador',
            description: 'Verificar nível do líquido de arrefecimento',
          ),
          ChecklistItem(
            id: 'nivel_oleo_freio',
            title: 'Nível do Óleo de Freio',
            description: 'Verificar nível do fluido de freio',
          ),
          ChecklistItem(
            id: 'nivel_combustivel',
            title: 'Nível de Combustível',
            description: 'Verificar quantidade de combustível',
          ),
          ChecklistItem(
            id: 'bateria',
            title: 'Bateria',
            description: 'Verificar terminais e fixação da bateria',
          ),
          ChecklistItem(
            id: 'correias',
            title: 'Correias',
            description: 'Verificar estado e tensão das correias',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'sistema_freios',
        title: 'Sistema de Freios',
        description: 'Verificação do sistema de freios',
        icon: Icons.car_repair,
        items: [
          ChecklistItem(
            id: 'freio_servico',
            title: 'Freio de Serviço',
            description: 'Testar eficiência do freio principal',
          ),
          ChecklistItem(
            id: 'freio_estacionamento',
            title: 'Freio de Estacionamento',
            description: 'Testar freio de mão',
          ),
          ChecklistItem(
            id: 'pedal_freio',
            title: 'Pedal de Freio',
            description: 'Verificar curso e firmeza do pedal',
          ),
          ChecklistItem(
            id: 'sistema_abs',
            title: 'Sistema ABS',
            description: 'Verificar funcionamento do ABS (se equipado)',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'sistema_iluminacao',
        title: 'Sistema de Iluminação',
        description: 'Verificação de luzes e sinalização',
        icon: Icons.lightbulb,
        items: [
          ChecklistItem(
            id: 'farol_baixo',
            title: 'Farol Baixo',
            description: 'Verificar funcionamento dos faróis baixos',
          ),
          ChecklistItem(
            id: 'farol_alto',
            title: 'Farol Alto',
            description: 'Verificar funcionamento dos faróis altos',
          ),
          ChecklistItem(
            id: 'lanternas_traseiras',
            title: 'Lanternas Traseiras',
            description: 'Verificar lanternas e luzes de freio',
          ),
          ChecklistItem(
            id: 'pisca_alerta',
            title: 'Pisca-alerta',
            description: 'Testar funcionamento do pisca-alerta',
          ),
          ChecklistItem(
            id: 'setas_direcao',
            title: 'Setas de Direção',
            description: 'Verificar sinalização de direção',
          ),
          ChecklistItem(
            id: 'luz_re',
            title: 'Luz de Ré',
            description: 'Testar funcionamento da luz de ré',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'equipamentos_seguranca',
        title: 'Equipamentos de Segurança',
        description: 'Verificação dos equipamentos de segurança',
        icon: Icons.security,
        items: [
          ChecklistItem(
            id: 'triangulo_seguranca',
            title: 'Triângulo de Segurança',
            description: 'Verificar presença e estado do triângulo',
          ),
          ChecklistItem(
            id: 'extintor_incendio',
            title: 'Extintor de Incêndio',
            description: 'Verificar validade e pressão do extintor',
          ),
          ChecklistItem(
            id: 'kit_primeiros_socorros',
            title: 'Kit Primeiros Socorros',
            description: 'Verificar presença e validade dos itens',
          ),
          ChecklistItem(
            id: 'macaco_chave_roda',
            title: 'Macaco e Chave de Roda',
            description: 'Verificar presença e funcionamento',
          ),
          ChecklistItem(
            id: 'cintos_seguranca',
            title: 'Cintos de Segurança',
            description: 'Testar funcionamento de todos os cintos',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'equipamentos_bombeiro',
        title: 'Equipamentos de Bombeiro',
        description: 'Verificação dos equipamentos específicos',
        icon: Icons.local_fire_department,
        items: [
          ChecklistItem(
            id: 'mangueiras',
            title: 'Mangueiras',
            description: 'Verificar estado e acoplamentos das mangueiras',
          ),
          ChecklistItem(
            id: 'esguichos',
            title: 'Esguichos',
            description: 'Verificar funcionamento dos esguichos',
          ),
          ChecklistItem(
            id: 'bomba_agua',
            title: 'Bomba d\'Água',
            description: 'Testar funcionamento da bomba',
          ),
          ChecklistItem(
            id: 'tanque_agua',
            title: 'Tanque de Água',
            description: 'Verificar nível e vedação do tanque',
          ),
          ChecklistItem(
            id: 'equipamentos_resgate',
            title: 'Equipamentos de Resgate',
            description: 'Verificar presença e estado dos equipamentos',
          ),
          ChecklistItem(
            id: 'escadas',
            title: 'Escadas',
            description: 'Verificar estado e funcionamento das escadas',
          ),
          ChecklistItem(
            id: 'equipamentos_protecao',
            title: 'Equipamentos de Proteção',
            description: 'Verificar EPIs e equipamentos de proteção',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'carroceria_interior',
        title: 'Carroceria e Interior',
        description: 'Verificação da carroceria e interior',
        icon: Icons.directions_car,
        items: [
          ChecklistItem(
            id: 'portas_fechaduras',
            title: 'Portas e Fechaduras',
            description: 'Verificar funcionamento de portas e travas',
          ),
          ChecklistItem(
            id: 'vidros_retrovisores',
            title: 'Vidros e Retrovisores',
            description: 'Verificar estado dos vidros e espelhos',
          ),
          ChecklistItem(
            id: 'painel_instrumentos',
            title: 'Painel de Instrumentos',
            description: 'Verificar funcionamento dos instrumentos',
          ),
          ChecklistItem(
            id: 'ar_condicionado',
            title: 'Ar Condicionado',
            description: 'Testar funcionamento do sistema de climatização',
          ),
          ChecklistItem(
            id: 'limpador_parabrisa',
            title: 'Limpador de Para-brisa',
            description: 'Verificar funcionamento dos limpadores',
          ),
          ChecklistItem(
            id: 'buzina',
            title: 'Buzina',
            description: 'Testar funcionamento da buzina',
          ),
        ],
      ),
      ChecklistCategory(
        id: 'documentacao',
        title: 'Documentação',
        description: 'Verificação da documentação da viatura',
        icon: Icons.description,
        items: [
          ChecklistItem(
            id: 'crlv',
            title: 'CRLV',
            description: 'Verificar presença e validade do CRLV',
          ),
          ChecklistItem(
            id: 'seguro_obrigatorio',
            title: 'Seguro Obrigatório',
            description: 'Verificar validade do DPVAT',
          ),
          ChecklistItem(
            id: 'certificado_tacografo',
            title: 'Certificado do Tacógrafo',
            description: 'Verificar validade (se aplicável)',
          ),
          ChecklistItem(
            id: 'manual_veiculo',
            title: 'Manual do Veículo',
            description: 'Verificar presença do manual',
          ),
        ],
      ),
    ];
  }

  // Método para obter categorias baseadas no tipo de veículo
  static List<ChecklistCategory> getCategoriesForVehicleType(String vehicleType) {
    // Por enquanto, retorna as categorias padrão para todos os tipos
    // Futuramente pode ser customizado por tipo de veículo
    return getDefaultCategories();
  }
}