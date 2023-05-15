library modbus;

import 'dart:typed_data';

export 'src/modbus_client.dart';
export 'src/modbus_server.dart';

enum ModbusMode {
  tcp,
  rtu,
  tcpAscii,
  rtuAscii,
}

enum ModbusFunction {
  none,
  readCoils,
  readDiscreteInputs,
  readHoldingRegisters,
  readInputRegisters,
  writeSingleCoil,
  writeSingleRegister,
  writeMultipleCoils,
  writeMultipleRegisters,
}

abstract class ModbusServer {
  Future<void> start(String host, int port);
  Future<void> stop();

  int getConnectionCount();
}

abstract class ModbusClient {
  Future<void> connect();
  Future<void> close();

  Future<List<bool?>> readCoils(int address, int quantity);
  Future<List<bool?>> readDiscreteInputs(int address, int quantity);
  Future<Uint16List> readHoldingRegisters(int address, int quantity);
  Future<Uint16List> readInputRegisters(int address, int quantity);

  Future<bool> writeSingleCoil(int address, bool value);
  Future<bool> writeSingleRegister(int address, int value);
  Future<bool> writeMultipleCoils(int address, List<bool> values);
  Future<bool> writeMultipleRegisters(int address, Uint16List values);
}

typedef OnReceive = void Function(Uint8List data);
typedef OnClose = void Function();

abstract class Connector {
  Future connect();
  Future close();

  void send(Uint8List data);

  late OnReceive onReceive;
  late OnClose onClose;
}
