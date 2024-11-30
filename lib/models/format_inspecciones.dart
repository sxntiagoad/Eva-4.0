import 'package:eva/models/week.dart';

Map<String, Map<String, Week>> formatInspecciones() => {
      'LUCES': {
        'Frontales': Week(),
        'Traseras': Week(),
        'Direccionales Delanteras de Parqueo': Week(),
        'Direccionales Traseras de Parqueo': Week(),
        'Luz Reversa': Week(),
        'Stop ': Week(),
      },
      'CABINA': {
        'Espejo Central Convexo': Week(),
        'Espejos Laterales': Week(),
        'Alarma de Retroceso': Week(),
        'Pito': Week(),
      },
      'FRENO DE SERVICIO': {
        'FRENO DE SERVICIO': Week(),
      },
      'FRENO DE EMERGENCIA': {
        'Recamaras': Week(),
        'Freno de Aire': Week(),
        'Compresor de Aire': Week(),
        'Direccion Suspension Terminales': Week(),
        'Pasadores, Suspension': Week(),
        'Cinturon de Seguridad': Week(),
        'Barra Antivuelco': Week(),
        'Vidrio Frontal en Buen Estado': Week(),
        'Limpia Brisas': Week(),
        'Asiento en Buenas Condiciones': Week(),
      },
      'INDICADORES DE SERVICIO': {
        'Indicador de Temperatura': Week(),
        'Indicador de Aceite': Week(),
        'Nivel de Combustible': Week(),
        'Aditivos de Radiador (Refrigerante)': Week(),
        'Medidor de Combustible': Week(),
      },
      'MOTOR': {
        'Escalera y Pasamanos': Week(),
        'Bateria y Cables': Week(),
        'Tapas de Radiador': Week(),
        'Tapa de Liquido de Frenos': Week(),
        'Tapa de Motor': Week(),
        'Tapa de Hidraulico': Week(),
        'Correas Motor': Week(),
      },
      'LLANTAS': {
        'Sin Cortaduras Profundas y Abultamientos': Week(),
        'Calibración de Llantas': Week(),
        'Rines': Week(),
      },
      'ESTADO MECANICO': {
        'Control de Fugas Hidraulicas': Week(),
        'Control Fugas de Aire': Week(),
        'Fuga de Agua en Radiador': Week(),
        'Fuga de Motor': Week(),
        'Fuga de Combustible': Week(),
        'Humedad en el Turbo': Week(),
      },
      'CAJA DE CAMBIOS': {
        'CAJA DE CAMBIOS': Week(),
      },
      'SUSPENSION': {
        'SUSPENSION': Week(),
      },
      'TRANSMISION/DIRECCION': {
        'TRANSMISION/DIRECCION': Week(),
      },
      'CARROCERIA/PUERTAS/VENTANAS': {
        'CARROCERIA/PUERTAS/VENTANAS': Week(),
      },
      'EQUIPO DE CARRETERA': {
        'Gato/Accesorios': Week(),
        'Equipo de Señalizacion': Week(),
        'Herramientas': Week(),
        'Linterna': Week(),
        'Llanta de Repuesto': Week(),
        'Botiquin de Primeros Auxilios': Week(),
        'Extintor / 20 lbs / 30 Ibs': Week(),
        'Tacos': Week(),
        'Otros': Week(),
      },
    };
