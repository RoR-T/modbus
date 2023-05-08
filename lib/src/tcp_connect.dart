import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';

class TCPConnect {
  final Logger log = Logger('TCPConnect');

  final String _host;
  final int _port;
  final Duration _timeout;

  Socket? _socket;

  TCPConnect(this._host, this._port, this._timeout);

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
  }

  void _onError(Object error, StackTrace stackTrace) {
    log.fine('onError: $error');
  }

  void _onDone() {
    log.fine('onDone');
  }

  void send(Uint8List data) {
    _socket?.add(data);
  }
}
