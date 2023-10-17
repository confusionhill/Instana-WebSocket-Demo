import 'package:instana_agent/instana_agent.dart';

Future<void> reportCustomEvents3() async {
  InstanaAgent.setMeta(key: 'custom_event_3', value: '003');
  await InstanaAgent.reportEvent(name: 'simple_custom_event_3');
  await InstanaAgent.reportEvent(
      name: 'complexCustomEvent',
      options: EventOptions()
        ..viewName = 'customViewName'
        ..startTime = DateTime.now().millisecondsSinceEpoch
        ..duration = 2 * 100000);
  await InstanaAgent.reportEvent(
      name: 'advancedCustomEvent',
      options: EventOptions()
        ..viewName = 'customViewName'
        ..startTime = DateTime.now().millisecondsSinceEpoch
        ..duration = 3 * 10000
        ..meta = {'customKey1': 'customValue1', 'customKey2': 'customValue2'});
  await InstanaAgent.startCapture(url: 'https://google.com/', method: 'GET')
      .then((marker) => marker
        ..responseStatusCode = 200
        ..responseSizeBody = 1000
        ..responseSizeBodyDecoded = 2400
        ..finish());
  await InstanaAgent.startCapture(
          url: 'https://google.com/failure', method: 'GET')
      .then((marker) => marker
        ..responseStatusCode = 500
        ..responseSizeBody = 1000
        ..responseSizeBodyDecoded = 2400
        ..errorMessage = 'Download of album failed'
        ..finish());
  await InstanaAgent.startCapture(
          url: 'https://google.com/cancel', method: 'POST')
      .then((marker) => marker.cancel());
}

Future<void> customEvents(key, value, eventName) async {
  InstanaAgent.setMeta(key: key, value: value);
  await InstanaAgent.reportEvent(name: eventName);
  await InstanaAgent.reportEvent(
      name: eventName,
      options: EventOptions()
        ..backendTracingID = 'abcde_$value'
        ..duration = 30 * 1000
        ..startTime = DateTime.now().millisecondsSinceEpoch
        ..viewName = 'viewname_abcde_$value'
        ..meta = {'key1': '0001', 'key2': '0002'});
  await InstanaAgent.startCapture(url: 'https://$eventName.com/', method: 'GET')
      .then((marker) => marker
        ..responseStatusCode = 200
        ..responseSizeBody = 1000
        ..responseSizeBodyDecoded = 2400
        ..finish());
}

Future<void> websocketEvents(action, startTime, duration) async {
  // InstanaAgent.setMeta(key: 'websocket', value: '0001');
  await InstanaAgent.reportEvent(
      name: 'websocket events',
      options: EventOptions()
        ..backendTracingID = 'backend traceid for websocket events'
        ..duration = duration
        ..startTime = startTime
        // ..viewName = 'websocket events'
        ..meta = {
          'key1': action,
        });
}

Future<void> httpEvents() async {
  await InstanaAgent.startCapture(url: 'https://google.com/', method: 'GET')
      .then((marker) => marker
        ..backendTracingID = 'traceidhttp'
        ..errorMessage = 'errorMessage'
        ..responseStatusCode = 200
        ..responseSizeBody = 1000
        ..responseSizeBodyDecoded = 2400
        ..finish());
}
