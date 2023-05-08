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

abstract class ModbusServer {
  Future<void> start(String host, int port);
  Future<void> stop();

  int getConnectionCount();
}

abstract class ModbusClient {
  Future<void> connect(String host, int port, int unitId, int timeout);
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
