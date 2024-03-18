import 'package:shared_preferences/shared_preferences.dart';

class UserPromptPre {
  static late SharedPreferences pref;

  static const _userprompt = 'default';

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static Future<void> setPrompt(String prompt) async {
    await pref.setString(_userprompt, prompt);
  }

  static String getPrompt() {
    // Use the null-aware operator (??) to provide a default value if the stored value is null
    return pref.getString(_userprompt) ?? 'default';
  }
  static Future<void> clearPrompt() async {
    await pref.remove(_userprompt);
  }
}
