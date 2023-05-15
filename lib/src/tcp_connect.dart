import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../modbus.dart';

class TCPConnector extends Connector {
  final Logger log = Logger('TCPConnector');

  final String _host;
  final int _port;
  final Duration _timeout;

  Socket? _socket;
  List<int> _recvBuffer = Uint8List(0);

  TCPConnector(this._host, this._port, this._timeout);

  @override
  Future<void> connect() async {
    _socket = await Socket.connect(_host, _port, timeout: _timeout);
    _socket?.listen((event) {
      _onData(event);
    }, onError: (error, stackTrace) {
      _onError(error, stackTrace);
    }, onDone: () {
      _onDone();
    }, cancelOnError: true);
  }

  void _onData(List<int> data) {
    log.fine('onData: $data');
    _recvBuffer = _recvBuffer + data;
    while (_recvBuffer.length >= 8) {
      var bytes = ByteData.view(Uint8List.fromList(_recvBuffer).buffer);
      int transactionID = bytes.getUint16(0, Endian.big);
      int length = bytes.getUint16(4, Endian.big);
      int unitID = bytes.getUint8(6);
      int function = bytes.getUint8(7);

      log.finest(
          'message: transactionID: $transactionID, length: $length, unitID: $unitID, function: $function');

      if (_recvBuffer.length >= 8 + length - 2) {
        var message = _recvBuffer.sublist(0, 8 + length - 2);
        _recvBuffer = _recvBuffer.sublist(8 + length - 2);

        onReceive(Uint8List.fromList(message));
      } else {
        break;
      }
    }
  }

  void _onError(Object error, StackTrace stackTrace) {
    log.fine('onError: $error');
  }

  void _onDone() {
    log.fine('onDone');
  }

  @override
  Future<void> close() async {
    _socket?.close();
  }

  @override
  void send(Uint8List data) {
    _socket?.add(data);
  }
}
