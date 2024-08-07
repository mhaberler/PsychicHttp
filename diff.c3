diff -c3 -r -w src/PsychicClient.cpp svkit/PsychicHttp/src/PsychicClient.cpp
*** src/PsychicClient.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicClient.cpp	Wed Aug  7 22:12:49 2024
***************
*** 2,13 ****
  #include "PsychicHttpServer.h"
  #include <lwip/sockets.h>
  
! PsychicClient::PsychicClient(httpd_handle_t server, int socket) :
!     _server(server),
      _socket(socket),
      _friend(NULL),
!     isNew(false)
! {}
  
  PsychicClient::~PsychicClient() {
  }
--- 2,12 ----
  #include "PsychicHttpServer.h"
  #include <lwip/sockets.h>
  
! PsychicClient::PsychicClient(httpd_handle_t server, int socket) : _server(server),
      _socket(socket),
      _friend(NULL),
!     isNew(false) {
! }
  
  PsychicClient::~PsychicClient() {
  }
***************
*** 62,68 ****
  
      // Convert to IPv4 string
      inet_ntop(AF_INET, &addr.sin6_addr.un.u32_addr[3], ipstr, sizeof(ipstr));
!     ESP_LOGI(PH_TAG, "Client Remote IP => %s", ipstr);
      address.fromString(ipstr);
  
      return address;
--- 61,67 ----
  
      // Convert to IPv4 string
      inet_ntop(AF_INET, &addr.sin6_addr.un.u32_addr[3], ipstr, sizeof(ipstr));
!     ESP_LOGV(PH_TAG, "Client Remote IP => %s", ipstr);
      address.fromString(ipstr);
  
      return address;
diff -c3 -r -w src/PsychicHandler.cpp svkit/PsychicHttp/src/PsychicHandler.cpp
*** src/PsychicHandler.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicHandler.cpp	Wed Aug  7 22:12:49 2024
***************
*** 7,14 ****
      _password(""),
      _method(DIGEST_AUTH),
      _realm(""),
!     _authFailMsg(""),
!     _subprotocol("")
  {}
  
  PsychicHandler::~PsychicHandler() {
--- 7,13 ----
      _password(""),
      _method(DIGEST_AUTH),
      _realm(""),
!     _authFailMsg("")
  {}
  
  PsychicHandler::~PsychicHandler() {
***************
*** 25,37 ****
  
  bool PsychicHandler::filter(PsychicRequest *request) {
      return _filter == NULL || _filter(request);
- }
- 
- void PsychicHandler::setSubprotocol(const String& subprotocol) {
-     this->_subprotocol = subprotocol;
- }
- const char* PsychicHandler::getSubprotocol() const {
-     return _subprotocol.c_str();
  }
  
  PsychicHandler* PsychicHandler::setAuthentication(const char *username, const char *password, HTTPAuthMethod method, const char *realm, const char *authFailMsg) {
--- 24,29 ----
diff -c3 -r -w src/PsychicHandler.h svkit/PsychicHttp/src/PsychicHandler.h
*** src/PsychicHandler.h	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicHandler.h	Wed Aug  7 22:12:49 2024
***************
*** 24,36 ****
      String _realm;
      String _authFailMsg;
  
-     String _subprotocol;
- 
      std::list<PsychicClient*> _clients;
  
    public:
      PsychicHandler();
!     virtual ~PsychicHandler();
  
      PsychicHandler* setFilter(PsychicRequestFilterFunction fn);
      bool filter(PsychicRequest *request);
--- 24,34 ----
      String _realm;
      String _authFailMsg;
  
      std::list<PsychicClient*> _clients;
  
    public:
      PsychicHandler();
!     ~PsychicHandler();
  
      PsychicHandler* setFilter(PsychicRequestFilterFunction fn);
      bool filter(PsychicRequest *request);
***************
*** 42,50 ****
      virtual bool isWebSocket() {
          return false;
      };
- 
-     void setSubprotocol(const String& subprotocol);
-     const char* getSubprotocol() const;
  
      PsychicClient * checkForNewClient(PsychicClient *client);
      void checkForClosedClient(PsychicClient *client);
--- 40,45 ----
diff -c3 -r -w src/PsychicHttpServer.cpp svkit/PsychicHttp/src/PsychicHttpServer.cpp
*** src/PsychicHttpServer.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicHttpServer.cpp	Wed Aug  7 22:12:49 2024
***************
*** 131,138 ****
          .method   = method,
          .handler  = PsychicEndpoint::requestCallback,
          .user_ctx = endpoint,
!         .is_websocket = handler->isWebSocket(),
!         .supported_subprotocol = handler->getSubprotocol()
      };
  
      // Register endpoint with ESP-IDF server
--- 131,137 ----
          .method   = method,
          .handler  = PsychicEndpoint::requestCallback,
          .user_ctx = endpoint,
!         .is_websocket = handler->isWebSocket()
      };
  
      // Register endpoint with ESP-IDF server
diff -c3 -r -w src/PsychicHttpServer.h svkit/PsychicHttp/src/PsychicHttpServer.h
*** src/PsychicHttpServer.h	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicHttpServer.h	Wed Aug  7 22:12:49 2024
***************
*** 24,30 ****
  
    public:
      PsychicHttpServer();
!     virtual ~PsychicHttpServer();
  
      //esp-idf specific stuff
      httpd_handle_t server;
--- 24,30 ----
  
    public:
      PsychicHttpServer();
!     ~PsychicHttpServer();
  
      //esp-idf specific stuff
      httpd_handle_t server;
diff -c3 -r -w src/PsychicHttpsServer.cpp svkit/PsychicHttp/src/PsychicHttpsServer.cpp
*** src/PsychicHttpsServer.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicHttpsServer.cpp	Wed Aug  7 22:12:49 2024
***************
*** 1,7 ****
  #include "PsychicHttpsServer.h"
  
- #ifdef CONFIG_ESP_HTTPS_SERVER_ENABLE
- 
  PsychicHttpsServer::PsychicHttpsServer() : PsychicHttpServer() {
      //for a SSL server
      ssl_config = HTTPD_SSL_CONFIG_DEFAULT();
--- 1,5 ----
***************
*** 25,39 ****
      this->_use_ssl = true;
  
      this->ssl_config.port_secure = port;
- 
- #if ESP_IDF_VERSION >= ESP_IDF_VERSION_VAL(5, 0, 2)
-     this->ssl_config.servercert = (uint8_t *)cert;
-     this->ssl_config.servercert_len = strlen(cert)+1;
- #else
      this->ssl_config.cacert_pem = (uint8_t *)cert;
      this->ssl_config.cacert_len = strlen(cert)+1;
- #endif
- 
      this->ssl_config.prvtkey_pem = (uint8_t *)private_key;
      this->ssl_config.prvtkey_len = strlen(private_key)+1;
  
--- 23,30 ----
***************
*** 53,57 ****
      else
          httpd_stop(this->server);
  }
- 
- #endif // CONFIG_ESP_HTTPS_SERVER_ENABLE
\ No newline at end of file
--- 44,46 ----
diff -c3 -r -w src/PsychicHttpsServer.h svkit/PsychicHttp/src/PsychicHttpsServer.h
*** src/PsychicHttpsServer.h	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicHttpsServer.h	Wed Aug  7 22:12:49 2024
***************
*** 1,11 ****
  #ifndef PsychicHttpsServer_h
  #define PsychicHttpsServer_h
  
- #ifdef CONFIG_ESP_HTTPS_SERVER_ENABLE
- 
  #include "PsychicCore.h"
  #include "PsychicHttpServer.h"
  #include <esp_https_server.h>
  #if !CONFIG_HTTPD_WS_SUPPORT
      #error PsychicHttpsServer cannot be used unless HTTPD_WS_SUPPORT is enabled in esp-http-server component configuration
  #endif
--- 1,10 ----
  #ifndef PsychicHttpsServer_h
  #define PsychicHttpsServer_h
  
  #include "PsychicCore.h"
  #include "PsychicHttpServer.h"
  #include <esp_https_server.h>
+ 
  #if !CONFIG_HTTPD_WS_SUPPORT
      #error PsychicHttpsServer cannot be used unless HTTPD_WS_SUPPORT is enabled in esp-http-server component configuration
  #endif
***************
*** 30,34 ****
  };
  
  #endif // PsychicHttpsServer_h
- 
- #endif // CONFIG_ESP_HTTPS_SERVER_ENABLE
\ No newline at end of file
--- 29,31 ----
diff -c3 -r -w src/PsychicJson.cpp svkit/PsychicHttp/src/PsychicJson.cpp
*** src/PsychicJson.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicJson.cpp	Wed Aug  7 22:12:49 2024
***************
*** 1,8 ****
  #include "PsychicJson.h"
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonResponse::PsychicJsonResponse(PsychicRequest *request, bool isArray, size_t maxJsonBufferSize) :
!     PsychicResponse(request),
      _jsonBuffer(maxJsonBufferSize) {
      setContentType(JSON_MIMETYPE);
      if (isArray)
--- 1,7 ----
  #include "PsychicJson.h"
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonResponse::PsychicJsonResponse(PsychicRequest *request, bool isArray, size_t maxJsonBufferSize) : PsychicResponse(request),
      _jsonBuffer(maxJsonBufferSize) {
      setContentType(JSON_MIMETYPE);
      if (isArray)
***************
*** 34,40 ****
      size_t buffer_size;
      char *buffer;
  
!     DUMP(length);
  
      //how big of a buffer do we want?
      if (length < JSON_BUFFER_SIZE)
--- 33,39 ----
      size_t buffer_size;
      char *buffer;
  
!     // DUMP(length);
  
      // how big of a buffer do we want?
      if (length < JSON_BUFFER_SIZE)
***************
*** 42,48 ****
      else
          buffer_size = JSON_BUFFER_SIZE;
  
!     DUMP(buffer_size);
  
      buffer = (char *)malloc(buffer_size);
      if (buffer == NULL) {
--- 41,47 ----
      else
          buffer_size = JSON_BUFFER_SIZE;
  
!     // DUMP(buffer_size);
  
      buffer = (char *)malloc(buffer_size);
      if (buffer == NULL) {
***************
*** 52,58 ****
  
      //send it in one shot or no?
      if (length < JSON_BUFFER_SIZE) {
!         TRACE();
  
          serializeJson(_root, buffer, buffer_size);
  
--- 51,57 ----
  
      // send it in one shot or no?
      if (length < JSON_BUFFER_SIZE) {
!         // TRACE();
  
          serializeJson(_root, buffer, buffer_size);
  
***************
*** 83,105 ****
  }
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonHandler::PsychicJsonHandler(size_t maxJsonBufferSize) :
!     _onRequest(NULL),
!     _maxJsonBufferSize(maxJsonBufferSize)
! {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest, size_t maxJsonBufferSize) :
!     _onRequest(onRequest),
!     _maxJsonBufferSize(maxJsonBufferSize)
! {}
  #else
! PsychicJsonHandler::PsychicJsonHandler() :
!     _onRequest(NULL)
! {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest) :
!     _onRequest(onRequest)
! {}
  #endif
  
  void PsychicJsonHandler::onRequest(PsychicJsonRequestCallback fn) {
--- 82,98 ----
  }
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonHandler::PsychicJsonHandler(size_t maxJsonBufferSize) : _onRequest(NULL),
!     _maxJsonBufferSize(maxJsonBufferSize) {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest, size_t maxJsonBufferSize) : _onRequest(onRequest),
!     _maxJsonBufferSize(maxJsonBufferSize) {
! }
  #else
! PsychicJsonHandler::PsychicJsonHandler() : _onRequest(NULL) {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest) : _onRequest(onRequest) {
! }
  #endif
  
  void PsychicJsonHandler::onRequest(PsychicJsonRequestCallback fn) {
diff -c3 -r -w src/PsychicRequest.cpp svkit/PsychicHttp/src/PsychicRequest.cpp
*** src/PsychicRequest.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicRequest.cpp	Wed Aug  7 22:12:49 2024
***************
*** 2,10 ****
  #include "http_status.h"
  #include "PsychicHttpServer.h"
  
! 
! PsychicRequest::PsychicRequest(PsychicHttpServer *server, httpd_req_t *req) :
!     _server(server),
      _req(req),
      _method(HTTP_GET),
      _query(""),
--- 2,8 ----
  #include "http_status.h"
  #include "PsychicHttpServer.h"
  
! PsychicRequest::PsychicRequest(PsychicHttpServer *server, httpd_req_t *req) : _server(server),
      _req(req),
      _method(HTTP_GET),
      _query(""),
***************
*** 254,259 ****
--- 252,258 ----
      if (query_len) {
          char query[query_len + 1];
          httpd_req_get_url_query_str(_req, query, sizeof(query));
+         _query = "";
          _query.concat(query);
  
          // parse them.
***************
*** 270,278 ****
      size_t start = 0;
      while (start < params.length()) {
          int end = params.indexOf('&', start);
!         if (end < 0) end = params.length();
          int equal = params.indexOf('=', start);
!         if (equal < 0 || equal > end) equal = end;
          String name = params.substring(start, equal);
          String value = equal + 1 < end ? params.substring(equal + 1, end) : String();
          addParam(name, value);
--- 269,279 ----
      size_t start = 0;
      while (start < params.length()) {
          int end = params.indexOf('&', start);
!         if (end < 0)
!             end = params.length();
          int equal = params.indexOf('=', start);
!         if (equal < 0 || equal > end)
!             equal = end;
          String name = params.substring(start, equal);
          String value = equal + 1 < end ? params.substring(equal + 1, end) : String();
          addParam(name, value);
***************
*** 390,396 ****
                  _cnonce = _extractParam(authReq, F("cnonce=\""),'\"');
              }
              String _H1 = md5str(String(username) + ':' + _realm + ':' + String(password));
!             ESP_LOGD(PH_TAG, "Hash of user:realm:pass=%s", _H1.c_str());
              String _H2 = "";
              if(_method == HTTP_GET) {
                  _H2 = md5str(String(F("GET:")) + _uri);
--- 391,397 ----
                  _cnonce = _extractParam(authReq, F("cnonce=\""), '\"');
              }
              String _H1 = md5str(String(username) + ':' + _realm + ':' + String(password));
!             ESP_LOGD(PH_TAG, "Hash of user:realm:pass=%s", _H1);
              String _H2 = "";
              if (_method == HTTP_GET) {
                  _H2 = md5str(String(F("GET:")) + _uri);
***************
*** 403,416 ****
              } else {
                  _H2 = md5str(String(F("GET:")) + _uri);
              }
!             ESP_LOGD(PH_TAG, "Hash of GET:uri=%s", _H2.c_str());
              String _responsecheck = "";
              if(authReq.indexOf("qop=auth") != -1 || authReq.indexOf("qop=\"auth\"") != -1) {
                  _responsecheck = md5str(_H1 + ':' + _nonce + ':' + _nc + ':' + _cnonce + F(":auth:") + _H2);
              } else {
                  _responsecheck = md5str(_H1 + ':' + _nonce + ':' + _H2);
              }
!             ESP_LOGD(PH_TAG, "The Proper response=%s", _responsecheck.c_str());
              if(_resp == _responsecheck) {
                  authReq = "";
                  return true;
--- 404,417 ----
              } else {
                  _H2 = md5str(String(F("GET:")) + _uri);
              }
!             ESP_LOGD(PH_TAG, "Hash of GET:uri=%s", _H2);
              String _responsecheck = "";
              if (authReq.indexOf("qop=auth") != -1 || authReq.indexOf("qop=\"auth\"") != -1) {
                  _responsecheck = md5str(_H1 + ':' + _nonce + ':' + _nc + ':' + _cnonce + F(":auth:") + _H2);
              } else {
                  _responsecheck = md5str(_H1 + ':' + _nonce + ':' + _H2);
              }
!             ESP_LOGD(PH_TAG, "The Proper response=%s", _responsecheck);
              if (_resp == _responsecheck) {
                  authReq = "";
                  return true;
***************
*** 432,438 ****
      char buffer[33];  // buffer to hold 32 Hex Digit + /0
      int i;
      for(i = 0; i < 4; i++) {
!         sprintf (buffer + (i*8), "%08lx", (unsigned long int)esp_random());
      }
      return String(buffer);
  }
--- 433,439 ----
      char buffer[33]; // buffer to hold 32 Hex Digit + /0
      int i;
      for (i = 0; i < 4; i++) {
!         sprintf(buffer + (i * 8), "%08lx", esp_random());
      }
      return String(buffer);
  }
diff -c3 -r -w src/PsychicResponse.cpp svkit/PsychicHttp/src/PsychicResponse.cpp
*** src/PsychicResponse.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicResponse.cpp	Wed Aug  7 22:12:49 2024
***************
*** 11,17 ****
  }
  
  PsychicResponse::~PsychicResponse() {
!     //clean up our header variables.  we have to do this on desctruct since httpd_resp_send doesn't store copies
      for (HTTPHeader header : _headers) {
          free(header.field);
          free(header.value);
--- 11,17 ----
  }
  
  PsychicResponse::~PsychicResponse() {
!     //clean up our header variables.  we have to do this since httpd_resp_send doesn't store copies
      for (HTTPHeader header : _headers) {
          free(header.field);
          free(header.value);
***************
*** 20,26 ****
  }
  
  void PsychicResponse::addHeader(const char *field, const char *value) {
!     //these get freed after send by the destructor
      HTTPHeader header;
      header.field =(char *)malloc(strlen(field)+1);
      header.value = (char *)malloc(strlen(value)+1);
--- 20,26 ----
  }
  
  void PsychicResponse::addHeader(const char *field, const char *value) {
!     //these get freed during send()
      HTTPHeader header;
      header.field =(char *)malloc(strlen(field)+1);
      header.value = (char *)malloc(strlen(value)+1);
***************
*** 114,129 ****
      //now do our individual headers
      for (HTTPHeader header : _headers)
          httpd_resp_set_hdr(this->_request->request(), header.field, header.value);
- 
-     // DO NOT RELEASE HEADERS HERE... released in the PsychicResponse destructor after they have been sent.
-     // httpd_resp_set_hdr just passes on the pointer, but its needed after this call.
-     // clean up our header variables after send
-     // for (HTTPHeader header : _headers)
-     // {
-     //   free(header.field);
-     //   free(header.value);
-     // }
-     // _headers.clear();
  }
  
  esp_err_t PsychicResponse::sendChunk(uint8_t *chunk, size_t chunksize) {
--- 114,119 ----
diff -c3 -r -w src/PsychicStreamResponse.cpp svkit/PsychicHttp/src/PsychicStreamResponse.cpp
*** src/PsychicStreamResponse.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicStreamResponse.cpp	Wed Aug  7 22:12:49 2024
***************
*** 16,22 ****
      setContentType(contentType.c_str());
  
      char buf[26+name.length()];
!     snprintf(buf, sizeof (buf), "attachment; filename=\"%s\"", name.c_str());
      addHeader("Content-Disposition", buf);
  }
  
--- 16,22 ----
      setContentType(contentType.c_str());
  
      char buf[26+name.length()];
!     snprintf(buf, sizeof (buf), "attachment; filename=\"%s\"", name);
      addHeader("Content-Disposition", buf);
  }
  
diff -c3 -r -w src/PsychicUploadHandler.cpp svkit/PsychicHttp/src/PsychicUploadHandler.cpp
*** src/PsychicUploadHandler.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicUploadHandler.cpp	Wed Aug  7 22:12:49 2024
***************
*** 27,40 ****
  
      //save it for later (multipart)
      _request = request;
!     _parsedLength = 0;
      /* File cannot be larger than a limit */
      if (request->contentLength() > request->server()->maxUploadSize) {
          ESP_LOGE(PH_TAG, "File too large : %d bytes", request->contentLength());
  
          /* Respond with 400 Bad Request */
          char error[50];
!         sprintf(error, "File size must be less than %lu bytes!", request->server()->maxUploadSize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
--- 27,40 ----
  
      //save it for later (multipart)
      _request = request;
! 
      /* File cannot be larger than a limit */
      if (request->contentLength() > request->server()->maxUploadSize) {
          ESP_LOGE(PH_TAG, "File too large : %d bytes", request->contentLength());
  
          /* Respond with 400 Bad Request */
          char error[50];
!         sprintf(error, "File size must be less than %u bytes!", request->server()->maxUploadSize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
diff -c3 -r -w src/PsychicWebHandler.cpp svkit/PsychicHttp/src/PsychicWebHandler.cpp
*** src/PsychicWebHandler.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicWebHandler.cpp	Wed Aug  7 22:12:49 2024
***************
*** 24,30 ****
  
          /* Respond with 400 Bad Request */
          char error[60];
!         sprintf(error, "Request body must be less than %lu bytes!", request->server()->maxRequestBodySize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
--- 24,30 ----
  
          /* Respond with 400 Bad Request */
          char error[60];
!         sprintf(error, "Request body must be less than %u bytes!", request->server()->maxRequestBodySize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
diff -c3 -r -w src/PsychicWebSocket.cpp svkit/PsychicHttp/src/PsychicWebSocket.cpp
*** src/PsychicWebSocket.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/PsychicWebSocket.cpp	Wed Aug  7 22:12:49 2024
***************
*** 4,11 ****
  /*  PsychicWebSocketRequest      */
  /*************************************/
  
! PsychicWebSocketRequest::PsychicWebSocketRequest(PsychicRequest *req) :
!     PsychicRequest(req->server(), req->request()),
      _client(req->client()) {
  }
  
--- 4,10 ----
  /*  PsychicWebSocketRequest      */
  /*************************************/
  
! PsychicWebSocketRequest::PsychicWebSocketRequest(PsychicRequest *req) : PsychicRequest(req->server(), req->request()),
      _client(req->client()) {
  }
  
***************
*** 65,72 ****
      return this->sendMessage(HTTPD_WS_TYPE_TEXT, buf, strlen(buf));
  }
  
! PsychicWebSocketHandler::PsychicWebSocketHandler() :
!     PsychicHandler(),
      _onOpen(NULL),
      _onFrame(NULL),
      _onClose(NULL) {
--- 64,70 ----
      return this->sendMessage(HTTPD_WS_TYPE_TEXT, buf, strlen(buf));
  }
  
! PsychicWebSocketHandler::PsychicWebSocketHandler() : PsychicHandler(),
      _onOpen(NULL),
      _onFrame(NULL),
      _onClose(NULL) {
***************
*** 158,164 ****
      }
  
      //okay, now try to load the packet
!     ESP_LOGI(PH_TAG, "frame len is %d", ws_pkt.len);
      if (ws_pkt.len) {
          /* ws_pkt.len + 1 is for NULL termination as we are expecting a string */
          buf = (uint8_t*) calloc(1, ws_pkt.len + 1);
--- 156,162 ----
      }
  
      // okay, now try to load the packet
!     ESP_LOGV(PH_TAG, "frame len is %d", ws_pkt.len);
      if (ws_pkt.len) {
          /* ws_pkt.len + 1 is for NULL termination as we are expecting a string */
          buf = (uint8_t *)calloc(1, ws_pkt.len + 1);
***************
*** 174,180 ****
              free(buf);
              return ret;
          }
!         ESP_LOGI(PH_TAG, "Got packet with message: %s", ws_pkt.payload);
      }
  
      // Text messages are our payload.
--- 172,178 ----
              free(buf);
              return ret;
          }
!         ESP_LOGV(PH_TAG, "Got packet with message: %s", ws_pkt.payload);
      }
  
      // Text messages are our payload.
***************
*** 186,195 ****
      //logging housekeeping
      if (ret != ESP_OK)
          ESP_LOGE(PH_TAG, "httpd_ws_send_frame failed with %s", esp_err_to_name(ret));
!     ESP_LOGI(PH_TAG, "ws_handler: httpd_handle_t=%p, sockfd=%d, client_info:%d",
!              request->server(),
!              httpd_req_to_sockfd(request->request()),
!              httpd_ws_get_fd_info(request->server()->server, httpd_req_to_sockfd(request->request())));
  
      //dont forget to release our buffer memory
      free(buf);
--- 184,191 ----
      // logging housekeeping
      if (ret != ESP_OK)
          ESP_LOGE(PH_TAG, "httpd_ws_send_frame failed with %s", esp_err_to_name(ret));
!     // ESP_LOGI(PH_TAG, "ws_handler: httpd_handle_t=%p, sockfd=%d, client_info:%d", request->server(),
!     // httpd_req_to_sockfd(request->request()), httpd_ws_get_fd_info(request->server(), httpd_req_to_sockfd(request->request())));
  
      // dont forget to release our buffer memory
      free(buf);
Only in src: TemplatePrinter.cpp
Only in src: TemplatePrinter.h
diff -c3 -r -w src/async_worker.cpp svkit/PsychicHttp/src/async_worker.cpp
*** src/async_worker.cpp	Wed Aug  7 21:40:39 2024
--- svkit/PsychicHttp/src/async_worker.cpp	Wed Aug  7 22:12:49 2024
***************
*** 161,167 ****
      if (async == NULL) {
          return ESP_ERR_NO_MEM;
      }
!     memcpy((void *)async, (void *)r, sizeof(httpd_req_t));
  
      // alloc async aux
      async->aux = (httpd_req_aux *)malloc(sizeof(struct httpd_req_aux));
--- 161,167 ----
      if (async == NULL) {
          return ESP_ERR_NO_MEM;
      }
!     memcpy(async, r, sizeof(httpd_req_t));
  
      // alloc async aux
      async->aux = (httpd_req_aux *)malloc(sizeof(struct httpd_req_aux));
