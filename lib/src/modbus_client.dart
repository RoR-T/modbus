import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../modbus.dart';

class ModbusClientTCP extends ModbusClient {
  final Logger log = Logger('ModbusClientTCP');

  @override
  Future<void> connect(String host, int port, int unitId, int timeout) async {}

  @override
  Future<void> close() async {}

  @override
  Future<List<bool?>> readCoils(int address, int quantity) async {
    Completer<List<bool?>> completer = Completer();

    return completer.future;
  }

  @override
  Future<List<bool?>> readDiscreteInputs(int address, int quantity) async {
    Completer<List<bool?>> completer = Completer();

    return completer.future;
  }

  @override
  Future<Uint16List> readHoldingRegisters(int address, int quantity) {
    Completer<Uint16List> completer = Completer();

    return completer.future;
  }

  @override
  Future<Uint16List> readInputRegisters(int address, int quantity) {
    Completer<Uint16List> completer = Completer();

    return completer.future;
  }

  @override
  Future<bool> writeSingleCoil(int address, bool value) {
    Completer<bool> completer = Completer();

    return completer.future;
  }

  @override
  Future<bool> writeSingleRegister(int address, int value) {
    Completer<bool> completer = Completer();

    return completer.future;
  }

  @override
  Future<bool> writeMultipleCoils(int address, List<bool> values) {
    Completer<bool> completer = Completer();

    return completer.future;
  }

  @override
  Future<bool> writeMultipleRegisters(int address, Uint16List values) {
    Completer<bool> completer = Completer();

    return completer.future;
  }
}
