import 'package:FaceApp/models/error_message.dart';

class ConstantMethodHelper {

  static String translateErrorResponse(ErrorMessage errorMessage) {
    switch (errorMessage.errCode) {
      case 1000: return "Caracteres incorrectos en la solicitud al servidor"; break;
      case 1001: return "Tipo de contenido inválido en solicitud"; break;
      case 1002: return "Faltan parámetros en la solicitud"; break;
      case 1003: return "Parámetro inválido en solicitud"; break;
      case 1004: return "El archivo es demasiado pesado"; break;
      case 3000: return "Se excedió el límite de solicitudes del plan"; break;
      case 3001: return "Servicio Facial no disponible temporalmente"; break;
      case 3002: return "Dirección de solicitud inválida"; break;
      case 3003: return "Parámetros de autenticación inválidos"; break;
      case 5000: return "Formato de foto inválida"; break;
      case 5001: return "Imagen subida inválida"; break;
      case 5002: return "No se encontraron caras en la imagen"; break;
      case 5003: return "El campo subject_id no se encontró"; break;
      case 5004: return "El nombre de la galería no se encontró"; break;
      case 5005: return "Hubo problemas al procesar la imagen"; break;
      case 5005: return "Procesamiento facial corrupto"; break;
      case 5010: return "Demasiadas caras en la imagen"; break;
      case 5011: return "Solicitud no disponible para plan actual"; break;
      case 5012: return "No se encontraron coincidencias"; break;
    }
    return "";
  }

}