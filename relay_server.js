const { WebSocketServer } = require('ws');
const server = new WebSocketServer({ host: '0.0.0.0', port: Number(process.env.PORT || 8080) });
const rooms = new Map();
function send(ws, data) { if (ws.readyState === 1) ws.send(JSON.stringify(data)); }
function leave(ws) {
  const room = rooms.get(ws.roomCode); if (!room) return;
  room.players = room.players.filter(p => p !== ws);
  for (const p of room.players) send(p, { type: 'error', message: '상대 연결이 종료됐습니다.' });
  rooms.delete(ws.roomCode);
}
server.on('connection', ws => {
  ws.on('message', raw => {
    let msg; try { msg = JSON.parse(raw.toString()); } catch { return send(ws, {type:'error', message:'잘못된 메시지'}); }
    if (msg.type === 'create') {
      let code = String(msg.room || '').toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 8);
      if (!code) code = Math.random().toString(36).slice(2, 6).toUpperCase();
      if (rooms.has(code)) return send(ws, {type:'error', message:'이미 사용 중인 방 코드입니다.'});
      rooms.set(code, {players:[ws], actions:{}}); ws.roomCode = code; ws.player = 1;
      send(ws, {type:'joined', room:code, player:1});
    } else if (msg.type === 'join') {
      const code = String(msg.room || '').toUpperCase(), room = rooms.get(code);
      if (!room) return send(ws, {type:'error', message:'방을 찾을 수 없습니다.'});
      if (room.players.length !== 1) return send(ws, {type:'error', message:'방이 이미 꽉 찼습니다.'});
      room.players.push(ws); ws.roomCode = code; ws.player = 2;
      send(ws, {type:'joined', room:code, player:2}); send(room.players[0], {type:'opponent_joined'});
    } else if (msg.type === 'action') {
      const room = rooms.get(ws.roomCode), action = Number(msg.action);
      if (!room || ![1,2,3,4,5].includes(action)) return;
      if (room.actions[ws.player] !== undefined) return send(ws, {type:'error', message:'이번 턴 행동을 이미 선택했습니다.'});
      room.actions[ws.player] = action;
      if (room.actions[1] !== undefined && room.actions[2] !== undefined) {
        const turn = {type:'turn', p1:room.actions[1], p2:room.actions[2]};
        room.players.forEach(p => send(p, turn)); room.actions = {};
      }
    }
  });
  ws.on('close', () => leave(ws));
});
server.on('listening', () => {
  console.log(`Dragon Ball room relay listening on ${server.address().port}`);
});


