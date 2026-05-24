
import '../countries/data/model/country_model.dart';

class PhoneFormatterHelper {
 static String formatPhone(String phone, CountryModel? country) {
    String formattedPhone = '';
    if (phone.startsWith('0') && country?.code == "+20") {
      formattedPhone = '${country?.code.substring(1)}${phone.substring(1)}';
    } else {
      formattedPhone = '${country?.code.substring(1)}$phone';
    }

    return formattedPhone;
  }
}
