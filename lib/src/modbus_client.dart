import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../modbus.dart';

class Request {
  int transactionID;
  Uint8List data;
  Completer<Uint8List> completer;

  Request(this.transactionID, this.data, this.completer);
}

class ModbusClientTCP extends ModbusClient {
  final Logger log = Logger('ModbusClientTCP');

  final int _unitID;
  final Connector _connector;
  int _transactionID = 0;

  final Map<int, Request> _waitResponse = HashMap();
  final Queue<Request> _queue = Queue();

  int get transactionID {
    _transactionID++;
    if (_transactionID > 65535) {
      _transactionID = 0;
    }
    return _transactionID;
  }

  ModbusClientTCP(this._connector, this._unitID) {
    _connector.onReceive = _onReceive;
    _connector.onClose = _onClose;
  }

  void _onReceive(Uint8List data) {
    var view = ByteData.view(data.buffer);
    var tid = view.getUint16(0, Endian.big);
    var function = view.getUint8(7);
    var req = _waitResponse.remove(tid);

    if (req == null) {
      log.warning('unknown transactionID: $tid');
      return;
    }

    if (function > 0x80) {
      log.warning('error response: $function');
      req.completer.complete(Uint8List(0));
    } else {
      log.fine('response: $function');
      req.completer.complete(data);
    }

    if (_queue.isNotEmpty) {
      var req = _queue.removeFirst();
      _waitResponse[req.transactionID] = req;
      _connector.send(req.data);
    }
  }

  void _onClose() {
    log.fine('onClose');
  }

  @override
  Future<void> connect() async {
    _connector.connect();
  }

  @override
  Future<void> close() async {
    _connector.close();
  }

  Future<Uint8List> sendAndReceive(int transcationID, Uint8List data) async {
    Completer<Uint8List> completer = Completer();

    if (_waitResponse.containsKey(transcationID)) {
      _queue.addLast(Request(transcationID, data, completer));
      log.fine('add $transactionID to queue($_queue.length)');
    } else {
      _waitResponse[transcationID] = Request(transcationID, data, completer);
      _connector.send(data);
    }

    return completer.future;
  }

  Future<Uint16List> _readRegisters(
      int transcationID, int quantity, Uint8List data) async {
    var response = await sendAndReceive(transcationID, data);
    var bytes = ByteData.view(response.buffer);

    var values = Uint16List(quantity);
    for (int i = 0; i < quantity; i++) {
      values[i] = bytes.getUint16(9 + i * 2, Endian.big);
    }

    return values;
  }

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
  Future<Uint16List> readHoldingRegisters(int address, int quantity) async {
    var header = Uint8List(6);
    var tid = transactionID;
    ByteData.view(header.buffer)
      ..setUint16(0, tid, Endian.big)
      ..setUint16(2, 0, Endian.big)
      ..setUint16(4, quantity, Endian.big);

    var adu = Uint8List(6);
    ByteData.view(adu.buffer)
      ..setUint8(0, _unitID)
      ..setUint8(1, ModbusFunction.readHoldingRegisters.index)
      ..setUint16(2, address, Endian.big)
      ..setUint16(4, quantity, Endian.big);

    Uint8List data = Uint8List.fromList(header + adu);

    return _readRegisters(tid, quantity, data);
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
