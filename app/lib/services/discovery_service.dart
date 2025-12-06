import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_config.dart';

class DiscoveryService {
  // Default multicast values used by the Go backend discovery
  static const _multicastAddr = '239.255.255.250';
  static const _port = 9999;
  static const _queryMessage = 'DISCOVER_USER_SERVICE';

  /// Tries to discover a service on the LAN via UDP multicast.
  /// If discovery succeeds it returns a base URL (http://address:port), otherwise returns fallbackBase.
  static Future<String> discoverOrFallback({
    Duration timeout = const Duration(milliseconds: 900),
    String fallbackBase = 'https://api.khanhnd.com',
  }) async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      // Make socket non-blocking and listen for responses
      final completer = Completer<String>();

      socket.broadcastEnabled = true;

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = socket.receive();
          if (dg == null) return;
          final msg = utf8.decode(dg.data);
          // Expect JSON like: {"service":"user-service","addr":"192.168.1.17","port":8081}
          try {
            final jsonMsg = jsonDecode(msg);
            if (jsonMsg['service'] == 'user-service' &&
                jsonMsg['addr'] != null &&
                jsonMsg['port'] != null) {
              final addr = jsonMsg['addr'];
              final port = jsonMsg['port'].toString();
              final base = 'http://$addr:$port';
              if (!completer.isCompleted) completer.complete(base);
            }
          } catch (e) {
            // ignore parse errors
          }
        }
      });

      final data = utf8.encode(_queryMessage);
      socket.send(data, InternetAddress(_multicastAddr), _port);

      // Wait for a message or timeout
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () => fallbackBase,
      );
      socket.close();

      // Set in ApiConfig (persist simple best-effort)
      ApiConfig.setBaseUrl(result);
      return result;
    } catch (e) {
      ApiConfig.setBaseUrl(fallbackBase);
      return fallbackBase;
    }
  }
}
