import 'package:newuicontrollor/class/shareddata.dart';
import 'package:newuicontrollor/web3/web3p.dart';

class Orchestration {
  static Future<bool> updatePeopleStatus(String _name) async {
    await SharedData.updatePeople(_name);
    List<String> _current = await SharedData.getPeople();
    for (var i = 0; i < _current.length; i++) {
      if (_current[i] == _name) {
        return true;
      }
    }
    return false;
  }

  static Future<void> homeOrchestrate(String _name) async {
    List<String> _current = await SharedData.getPeople();
    print(_current);
    bool _kai = false;
    bool _kang = false;
    bool _justin = false;
    for (var i = 0; i < _current.length; i++) {
      if (_current[i] == 'Kai') {
        _kai = true;
      }
      if (_current[i] == 'Kang') {
        _kang = true;
      }
      if (_current[i] == 'Justin') {
        _justin = true;
      }
    }
    if (_kai && !_kang && !_justin) {
      Web3P.web3orchestration('_onlyKai');
    }
    if (!_kai && _kang && !_justin) {
      Web3P.web3orchestration('_onlyKang');
    }
    if (!_kai && !_kang && _justin) {
      Web3P.web3orchestration('_onlyJustin');
    }
    if (_kai && _kang && !_justin) {
      Web3P.web3orchestration('_bothKaiAndKang');
    }
    if (_kai && !_kang && _justin) {
      Web3P.web3orchestration('_bothKaiAndJustin');
    }
    if (!_kai && _kang && _justin) {
      Web3P.web3orchestration('_bothJustinAndKang');
    }
    if (_kai && _kang && _justin) {
      Web3P.web3orchestration('_allThree');
    }
    Web3P.web3orchestration('_nobodyHome');
  }
}
