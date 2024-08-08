diff -c3 -r -w src/PsychicClient.cpp svkit/PsychicHttp/src/PsychicClient.cpp
*** src/PsychicClient.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicClient.cpp	Thu Aug  8 07:15:01 2024
***************
*** 2,13 ****
  #include "PsychicHttpServer.h"
  #include <lwip/sockets.h>
  
! PsychicClient::PsychicClient(httpd_handle_t server, int socket) :
!     _server(server),
      _socket(socket),
      _friend(NULL),
      isNew(false)
! {}
  
  PsychicClient::~PsychicClient()
  {
--- 2,13 ----
  #include "PsychicHttpServer.h"
  #include <lwip/sockets.h>
  
! PsychicClient::PsychicClient(httpd_handle_t server, int socket) : _server(server),
      _socket(socket),
      _friend(NULL),
      isNew(false)
! {
! }
  
  PsychicClient::~PsychicClient()
  {
***************
*** 70,76 ****
  
      // Convert to IPv4 string
      inet_ntop(AF_INET, &addr.sin6_addr.un.u32_addr[3], ipstr, sizeof(ipstr));
!     ESP_LOGI(PH_TAG, "Client Remote IP => %s", ipstr);
      address.fromString(ipstr);
  
      return address;
--- 70,76 ----
  
      // Convert to IPv4 string
      inet_ntop(AF_INET, &addr.sin6_addr.un.u32_addr[3], ipstr, sizeof(ipstr));
!     ESP_LOGV(PH_TAG, "Client Remote IP => %s", ipstr);
      address.fromString(ipstr);
  
      return address;
diff -c3 -r -w src/PsychicHandler.cpp svkit/PsychicHttp/src/PsychicHandler.cpp
*** src/PsychicHandler.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicHandler.cpp	Thu Aug  8 07:15:01 2024
***************
*** 7,14 ****
      _password(""),
      _method(DIGEST_AUTH),
      _realm(""),
!     _authFailMsg(""),
!     _subprotocol("")
  {}
  
  PsychicHandler::~PsychicHandler()
--- 7,13 ----
      _password(""),
      _method(DIGEST_AUTH),
      _realm(""),
!     _authFailMsg("")
  {}
  
  PsychicHandler::~PsychicHandler()
***************
*** 28,42 ****
  bool PsychicHandler::filter(PsychicRequest *request)
  {
      return _filter == NULL || _filter(request);
- }
- 
- void PsychicHandler::setSubprotocol(const String& subprotocol)
- {
-     this->_subprotocol = subprotocol;
- }
- const char* PsychicHandler::getSubprotocol() const
- {
-     return _subprotocol.c_str();
  }
  
  PsychicHandler* PsychicHandler::setAuthentication(const char *username, const char *password, HTTPAuthMethod method, const char *realm, const char *authFailMsg)
--- 27,32 ----
diff -c3 -r -w src/PsychicHandler.h svkit/PsychicHttp/src/PsychicHandler.h
*** src/PsychicHandler.h	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicHandler.h	Thu Aug  8 07:15:01 2024
***************
*** 25,37 ****
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
--- 25,35 ----
      String _realm;
      String _authFailMsg;
  
      std::list<PsychicClient*> _clients;
  
  public:
      PsychicHandler();
!     ~PsychicHandler();
  
      PsychicHandler* setFilter(PsychicRequestFilterFunction fn);
      bool filter(PsychicRequest *request);
***************
*** 44,52 ****
      {
          return false;
      };
- 
-     void setSubprotocol(const String& subprotocol);
-     const char* getSubprotocol() const;
  
      PsychicClient * checkForNewClient(PsychicClient *client);
      void checkForClosedClient(PsychicClient *client);
--- 42,47 ----
diff -c3 -r -w src/PsychicHttpServer.cpp svkit/PsychicHttp/src/PsychicHttpServer.cpp
*** src/PsychicHttpServer.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicHttpServer.cpp	Thu Aug  8 07:15:01 2024
***************
*** 146,153 ****
          .method   = method,
          .handler  = PsychicEndpoint::requestCallback,
          .user_ctx = endpoint,
!         .is_websocket = handler->isWebSocket(),
!         .supported_subprotocol = handler->getSubprotocol()
      };
  
      // Register endpoint with ESP-IDF server
--- 146,152 ----
          .method   = method,
          .handler  = PsychicEndpoint::requestCallback,
          .user_ctx = endpoint,
!         .is_websocket = handler->isWebSocket()
      };
  
      // Register endpoint with ESP-IDF server
diff -c3 -r -w src/PsychicHttpServer.h svkit/PsychicHttp/src/PsychicHttpServer.h
*** src/PsychicHttpServer.h	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicHttpServer.h	Thu Aug  8 07:15:01 2024
***************
*** 25,31 ****
  
  public:
      PsychicHttpServer();
!     virtual ~PsychicHttpServer();
  
      //esp-idf specific stuff
      httpd_handle_t server;
--- 25,31 ----
  
  public:
      PsychicHttpServer();
!     ~PsychicHttpServer();
  
      //esp-idf specific stuff
      httpd_handle_t server;
diff -c3 -r -w src/PsychicHttpsServer.cpp svkit/PsychicHttp/src/PsychicHttpsServer.cpp
*** src/PsychicHttpsServer.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicHttpsServer.cpp	Thu Aug  8 07:15:01 2024
***************
*** 1,7 ****
  #include "PsychicHttpsServer.h"
  
- #ifdef CONFIG_ESP_HTTPS_SERVER_ENABLE
- 
  PsychicHttpsServer::PsychicHttpsServer() : PsychicHttpServer()
  {
      //for a SSL server
--- 1,5 ----
***************
*** 27,41 ****
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
  
--- 25,32 ----
***************
*** 57,61 ****
      else
          httpd_stop(this->server);
  }
- 
- #endif // CONFIG_ESP_HTTPS_SERVER_ENABLE
\ No newline at end of file
--- 48,50 ----
diff -c3 -r -w src/PsychicHttpsServer.h svkit/PsychicHttp/src/PsychicHttpsServer.h
*** src/PsychicHttpsServer.h	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicHttpsServer.h	Thu Aug  8 07:15:01 2024
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
*** 31,35 ****
  };
  
  #endif // PsychicHttpsServer_h
- 
- #endif // CONFIG_ESP_HTTPS_SERVER_ENABLE
\ No newline at end of file
--- 30,32 ----
diff -c3 -r -w src/PsychicJson.cpp svkit/PsychicHttp/src/PsychicJson.cpp
*** src/PsychicJson.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicJson.cpp	Thu Aug  8 07:15:01 2024
***************
*** 1,8 ****
  #include "PsychicJson.h"
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonResponse::PsychicJsonResponse(PsychicRequest *request, bool isArray, size_t maxJsonBufferSize) :
!     PsychicResponse(request),
      _jsonBuffer(maxJsonBufferSize)
  {
      setContentType(JSON_MIMETYPE);
--- 1,7 ----
  #include "PsychicJson.h"
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonResponse::PsychicJsonResponse(PsychicRequest *request, bool isArray, size_t maxJsonBufferSize) : PsychicResponse(request),
      _jsonBuffer(maxJsonBufferSize)
  {
      setContentType(JSON_MIMETYPE);
***************
*** 39,45 ****
      size_t buffer_size;
      char *buffer;
  
!     DUMP(length);
  
      //how big of a buffer do we want?
      if (length < JSON_BUFFER_SIZE)
--- 38,44 ----
      size_t buffer_size;
      char *buffer;
  
!     // DUMP(length);
  
      // how big of a buffer do we want?
      if (length < JSON_BUFFER_SIZE)
***************
*** 47,53 ****
      else
          buffer_size = JSON_BUFFER_SIZE;
  
!     DUMP(buffer_size);
  
      buffer = (char *)malloc(buffer_size);
      if (buffer == NULL)
--- 46,52 ----
      else
          buffer_size = JSON_BUFFER_SIZE;
  
!     // DUMP(buffer_size);
  
      buffer = (char *)malloc(buffer_size);
      if (buffer == NULL)
***************
*** 59,65 ****
      //send it in one shot or no?
      if (length < JSON_BUFFER_SIZE)
      {
!         TRACE();
  
          serializeJson(_root, buffer, buffer_size);
  
--- 58,64 ----
      // send it in one shot or no?
      if (length < JSON_BUFFER_SIZE)
      {
!         // TRACE();
  
          serializeJson(_root, buffer, buffer_size);
  
***************
*** 92,114 ****
  }
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonHandler::PsychicJsonHandler(size_t maxJsonBufferSize) :
!     _onRequest(NULL),
!     _maxJsonBufferSize(maxJsonBufferSize)
! {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest, size_t maxJsonBufferSize) :
!     _onRequest(onRequest),
      _maxJsonBufferSize(maxJsonBufferSize)
! {}
  #else
! PsychicJsonHandler::PsychicJsonHandler() :
!     _onRequest(NULL)
! {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest) :
!     _onRequest(onRequest)
! {}
  #endif
  
  void PsychicJsonHandler::onRequest(PsychicJsonRequestCallback fn)
--- 91,109 ----
  }
  
  #ifdef ARDUINOJSON_6_COMPATIBILITY
! PsychicJsonHandler::PsychicJsonHandler(size_t maxJsonBufferSize) : _onRequest(NULL),
!     _maxJsonBufferSize(maxJsonBufferSize) {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest, size_t maxJsonBufferSize) : _onRequest(onRequest),
      _maxJsonBufferSize(maxJsonBufferSize)
! {
! }
  #else
! PsychicJsonHandler::PsychicJsonHandler() : _onRequest(NULL) {};
  
! PsychicJsonHandler::PsychicJsonHandler(PsychicJsonRequestCallback onRequest) : _onRequest(onRequest)
! {
! }
  #endif
  
  void PsychicJsonHandler::onRequest(PsychicJsonRequestCallback fn)
diff -c3 -r -w src/PsychicRequest.cpp svkit/PsychicHttp/src/PsychicRequest.cpp
*** src/PsychicRequest.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicRequest.cpp	Thu Aug  8 07:15:01 2024
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
*** 292,297 ****
--- 290,296 ----
      {
          char query[query_len + 1];
          httpd_req_get_url_query_str(_req, query, sizeof(query));
+         _query = "";
          _query.concat(query);
  
          // parse them.
***************
*** 311,319 ****
      while (start < params.length())
      {
          int end = params.indexOf('&', start);
!         if (end < 0) end = params.length();
          int equal = params.indexOf('=', start);
!         if (equal < 0 || equal > end) equal = end;
          String name = params.substring(start, equal);
          String value = equal + 1 < end ? params.substring(equal + 1, end) : String();
          addParam(name, value);
--- 310,320 ----
      while (start < params.length())
      {
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
*** 451,457 ****
                  _cnonce = _extractParam(authReq, F("cnonce=\""),'\"');
              }
              String _H1 = md5str(String(username) + ':' + _realm + ':' + String(password));
!             ESP_LOGD(PH_TAG, "Hash of user:realm:pass=%s", _H1.c_str());
              String _H2 = "";
              if(_method == HTTP_GET)
              {
--- 452,458 ----
                  _cnonce = _extractParam(authReq, F("cnonce=\""), '\"');
              }
              String _H1 = md5str(String(username) + ':' + _realm + ':' + String(password));
!             ESP_LOGD(PH_TAG, "Hash of user:realm:pass=%s", _H1);
              String _H2 = "";
              if (_method == HTTP_GET)
              {
***************
*** 473,479 ****
              {
                  _H2 = md5str(String(F("GET:")) + _uri);
              }
!             ESP_LOGD(PH_TAG, "Hash of GET:uri=%s", _H2.c_str());
              String _responsecheck = "";
              if(authReq.indexOf("qop=auth") != -1 || authReq.indexOf("qop=\"auth\"") != -1)
              {
--- 474,480 ----
              {
                  _H2 = md5str(String(F("GET:")) + _uri);
              }
!             ESP_LOGD(PH_TAG, "Hash of GET:uri=%s", _H2);
              String _responsecheck = "";
              if (authReq.indexOf("qop=auth") != -1 || authReq.indexOf("qop=\"auth\"") != -1)
              {
***************
*** 483,489 ****
              {
                  _responsecheck = md5str(_H1 + ':' + _nonce + ':' + _H2);
              }
!             ESP_LOGD(PH_TAG, "The Proper response=%s", _responsecheck.c_str());
              if(_resp == _responsecheck)
              {
                  authReq = "";
--- 484,490 ----
              {
                  _responsecheck = md5str(_H1 + ':' + _nonce + ':' + _H2);
              }
!             ESP_LOGD(PH_TAG, "The Proper response=%s", _responsecheck);
              if (_resp == _responsecheck)
              {
                  authReq = "";
***************
*** 509,515 ****
      int i;
      for(i = 0; i < 4; i++)
      {
!         sprintf (buffer + (i*8), "%08lx", (unsigned long int)esp_random());
      }
      return String(buffer);
  }
--- 510,516 ----
      int i;
      for (i = 0; i < 4; i++)
      {
!         sprintf(buffer + (i * 8), "%08lx", esp_random());
      }
      return String(buffer);
  }
diff -c3 -r -w src/PsychicResponse.cpp svkit/PsychicHttp/src/PsychicResponse.cpp
*** src/PsychicResponse.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicResponse.cpp	Thu Aug  8 07:15:01 2024
***************
*** 13,19 ****
  
  PsychicResponse::~PsychicResponse()
  {
!     //clean up our header variables.  we have to do this on desctruct since httpd_resp_send doesn't store copies
      for (HTTPHeader header : _headers)
      {
          free(header.field);
--- 13,19 ----
  
  PsychicResponse::~PsychicResponse()
  {
!     //clean up our header variables.  we have to do this since httpd_resp_send doesn't store copies
      for (HTTPHeader header : _headers)
      {
          free(header.field);
***************
*** 24,30 ****
  
  void PsychicResponse::addHeader(const char *field, const char *value)
  {
!     //these get freed after send by the destructor
      HTTPHeader header;
      header.field =(char *)malloc(strlen(field)+1);
      header.value = (char *)malloc(strlen(value)+1);
--- 24,30 ----
  
  void PsychicResponse::addHeader(const char *field, const char *value)
  {
!     //these get freed during send()
      HTTPHeader header;
      header.field =(char *)malloc(strlen(field)+1);
      header.value = (char *)malloc(strlen(value)+1);
***************
*** 128,143 ****
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
  
  esp_err_t PsychicResponse::sendChunk(uint8_t *chunk, size_t chunksize)
--- 128,133 ----
diff -c3 -r -w src/PsychicStreamResponse.cpp svkit/PsychicHttp/src/PsychicStreamResponse.cpp
*** src/PsychicStreamResponse.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicStreamResponse.cpp	Thu Aug  8 07:15:01 2024
***************
*** 18,24 ****
      setContentType(contentType.c_str());
  
      char buf[26+name.length()];
!     snprintf(buf, sizeof (buf), "attachment; filename=\"%s\"", name.c_str());
      addHeader("Content-Disposition", buf);
  }
  
--- 18,24 ----
      setContentType(contentType.c_str());
  
      char buf[26+name.length()];
!     snprintf(buf, sizeof (buf), "attachment; filename=\"%s\"", name);
      addHeader("Content-Disposition", buf);
  }
  
diff -c3 -r -w src/PsychicUploadHandler.cpp svkit/PsychicHttp/src/PsychicUploadHandler.cpp
*** src/PsychicUploadHandler.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicUploadHandler.cpp	Thu Aug  8 07:15:01 2024
***************
*** 29,35 ****
  
      //save it for later (multipart)
      _request = request;
!     _parsedLength = 0;
      /* File cannot be larger than a limit */
      if (request->contentLength() > request->server()->maxUploadSize)
      {
--- 29,35 ----
  
      //save it for later (multipart)
      _request = request;
! 
      /* File cannot be larger than a limit */
      if (request->contentLength() > request->server()->maxUploadSize)
      {
***************
*** 37,43 ****
  
          /* Respond with 400 Bad Request */
          char error[50];
!         sprintf(error, "File size must be less than %lu bytes!", request->server()->maxUploadSize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
--- 37,43 ----
  
          /* Respond with 400 Bad Request */
          char error[50];
!         sprintf(error, "File size must be less than %u bytes!", request->server()->maxUploadSize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
diff -c3 -r -w src/PsychicWebHandler.cpp svkit/PsychicHttp/src/PsychicWebHandler.cpp
*** src/PsychicWebHandler.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicWebHandler.cpp	Thu Aug  8 07:15:01 2024
***************
*** 27,33 ****
  
          /* Respond with 400 Bad Request */
          char error[60];
!         sprintf(error, "Request body must be less than %lu bytes!", request->server()->maxRequestBodySize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
--- 27,33 ----
  
          /* Respond with 400 Bad Request */
          char error[60];
!         sprintf(error, "Request body must be less than %u bytes!", request->server()->maxRequestBodySize);
          httpd_resp_send_err(request->request(), HTTPD_400_BAD_REQUEST, error);
  
          /* Return failure to close underlying connection else the incoming file content will keep the socket busy */
diff -c3 -r -w src/PsychicWebSocket.cpp svkit/PsychicHttp/src/PsychicWebSocket.cpp
*** src/PsychicWebSocket.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/PsychicWebSocket.cpp	Thu Aug  8 07:15:01 2024
***************
*** 4,11 ****
  /*  PsychicWebSocketRequest      */
  /*************************************/
  
! PsychicWebSocketRequest::PsychicWebSocketRequest(PsychicRequest *req) :
!     PsychicRequest(req->server(), req->request()),
      _client(req->client())
  {
  }
--- 4,10 ----
  /*  PsychicWebSocketRequest      */
  /*************************************/
  
! PsychicWebSocketRequest::PsychicWebSocketRequest(PsychicRequest *req) : PsychicRequest(req->server(), req->request()),
      _client(req->client())
  {
  }
***************
*** 76,83 ****
      return this->sendMessage(HTTPD_WS_TYPE_TEXT, buf, strlen(buf));
  }
  
! PsychicWebSocketHandler::PsychicWebSocketHandler() :
!     PsychicHandler(),
      _onOpen(NULL),
      _onFrame(NULL),
      _onClose(NULL)
--- 75,81 ----
      return this->sendMessage(HTTPD_WS_TYPE_TEXT, buf, strlen(buf));
  }
  
! PsychicWebSocketHandler::PsychicWebSocketHandler() : PsychicHandler(),
      _onOpen(NULL),
      _onFrame(NULL),
      _onClose(NULL)
***************
*** 184,190 ****
      }
  
      //okay, now try to load the packet
!     ESP_LOGI(PH_TAG, "frame len is %d", ws_pkt.len);
      if (ws_pkt.len)
      {
          /* ws_pkt.len + 1 is for NULL termination as we are expecting a string */
--- 182,188 ----
      }
  
      // okay, now try to load the packet
!     ESP_LOGV(PH_TAG, "frame len is %d", ws_pkt.len);
      if (ws_pkt.len)
      {
          /* ws_pkt.len + 1 is for NULL termination as we are expecting a string */
***************
*** 203,209 ****
              free(buf);
              return ret;
          }
!         ESP_LOGI(PH_TAG, "Got packet with message: %s", ws_pkt.payload);
      }
  
      // Text messages are our payload.
--- 201,207 ----
              free(buf);
              return ret;
          }
!         ESP_LOGV(PH_TAG, "Got packet with message: %s", ws_pkt.payload);
      }
  
      // Text messages are our payload.
***************
*** 216,225 ****
      //logging housekeeping
      if (ret != ESP_OK)
          ESP_LOGE(PH_TAG, "httpd_ws_send_frame failed with %s", esp_err_to_name(ret));
!     ESP_LOGI(PH_TAG, "ws_handler: httpd_handle_t=%p, sockfd=%d, client_info:%d",
!              request->server(),
!              httpd_req_to_sockfd(request->request()),
!              httpd_ws_get_fd_info(request->server()->server, httpd_req_to_sockfd(request->request())));
  
      //dont forget to release our buffer memory
      free(buf);
--- 214,221 ----
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
*** src/async_worker.cpp	Thu Aug  8 07:14:49 2024
--- svkit/PsychicHttp/src/async_worker.cpp	Thu Aug  8 07:15:01 2024
***************
*** 183,189 ****
      {
          return ESP_ERR_NO_MEM;
      }
!     memcpy((void *)async, (void *)r, sizeof(httpd_req_t));
  
      // alloc async aux
      async->aux = (httpd_req_aux *)malloc(sizeof(struct httpd_req_aux));
--- 183,189 ----
      {
          return ESP_ERR_NO_MEM;
      }
!     memcpy(async, r, sizeof(httpd_req_t));
  
      // alloc async aux
      async->aux = (httpd_req_aux *)malloc(sizeof(struct httpd_req_aux));
