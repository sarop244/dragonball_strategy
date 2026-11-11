# Dragon Ball Strategy 온라인 멀티

## 동작 구성
- Godot 게임은 WebSocket으로 `network_client.gd`에 연결합니다.
- `relay_server.js`는 방 코드와 최대 두 플레이어를 관리하고, 양쪽 행동이 도착하면 한 턴으로 전달합니다.
- 서버는 반드시 인터넷에서 접속 가능한 HTTPS/WSS 주소로 배포해야 합니다. `wss://YOUR-SERVER/ws`는 자리표시자라 실제 주소로 바꾸어야 합니다.

## 릴레이 서버 실행
Node.js 18 이상이 설치된 서버에서 프로젝트의 relay 파일을 배포한 뒤 실행:

```sh
npm install
npm start
```

이 서버는 기본으로 `0.0.0.0:8080`에서 WebSocket 연결을 받습니다. 공개 웹 게임에 연결할 때는 HTTPS reverse proxy에서 `/ws`를 WebSocket 업그레이드로 `localhost:8080`에 전달하고, 브라우저가 신뢰하는 TLS 인증서를 사용하세요. Render, Fly.io, Railway 등 Node.js 서비스 배포 플랫폼을 쓸 수도 있습니다. 플랫폼의 공개 WSS endpoint를 Godot 시작 메뉴의 서버 주소에 입력합니다.

## 게임 사용
2인용 버튼을 누른 다음 서버 주소를 입력합니다. 한 명은 방 만들기, 다른 한 명은 표시된 방 코드를 입력하고 방 참가를 누릅니다. 두 플레이어가 행동을 고르면 릴레이 서버가 행동을 짝지어 양쪽에 전달합니다.

온라인 게임은 브라우저에서 플레이하려면 Godot Web export가 필요하고, 블로그는 Web export 산출물을 iframe 또는 HTML 삽입으로 게시할 수 있어야 합니다. 네이티브 Godot 실행 파일도 동일한 WSS 서버에 연결할 수 있습니다.
