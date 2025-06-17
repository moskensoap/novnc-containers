class WebAudio {
    constructor(url=null) {
        if (url !== null)
            this.url = url
        else {
            if (window.location.protocol === "https:")
                this.url = "wss"
            else
                this.url = "ws"
            this.url += "://" + window.location.host + "/websockify?token=pulse"
        }

        this.connected = false;

        // constants for audio behavior
        this.maximumAudioLag = 1.5;
        this.syncLagInterval = 5000;
        this.updateBufferEvery = 20;
        this.reduceBufferInterval = 500;
        this.maximumSecondsOfBuffering = 1;
        this.connectionCheckInterval = 500;

        setInterval(() => this.updateQueue(), this.updateBufferEvery);
        setInterval(() => this.syncInterval(), this.syncLagInterval);
        setInterval(() => this.reduceBuffer(), this.reduceBufferInterval);
        setInterval(() => this.tryLastPacket(), this.connectionCheckInterval);
    }

    registerHandlers() {
        this.mediaSource.addEventListener('sourceended', e => this.socketDisconnected(e))
        this.mediaSource.addEventListener('sourceclose', e => this.socketDisconnected(e))
        this.mediaSource.addEventListener('error', e => this.socketDisconnected(e))
        this.buffer.addEventListener('error', e => this.socketDisconnected(e))
        this.buffer.addEventListener('abort', e => this.socketDisconnected(e))
    }

    start() {
        if (!!this.connected) return;
        if (!!this.audio) this.audio.remove();
        this.queue = null;

        this.mediaSource = new MediaSource()
        this.mediaSource.addEventListener('sourceopen', e => this.onSourceOpen())

        this.audio = document.createElement('audio');
        this.audio.src = window.URL.createObjectURL(this.mediaSource);
        this.audio.play();
    }

    wsConnect() {
        if (!!this.socket) this.socket.close();

        this.socket = new WebSocket(this.url, ['binary', 'base64']);
        this.socket.binaryType = 'arraybuffer';
        this.socket.addEventListener('message', e => this.websocketDataArrived(e), false);
    }

    onSourceOpen(e) {
        this.buffer = this.mediaSource.addSourceBuffer('audio/webm; codecs="opus"')
        this.registerHandlers();
        this.wsConnect();
    }

    websocketDataArrived(e) {
        this.lastPacket = Date.now();
        this.connected = true;
        this.queue = this.queue == null ? e.data : this.concat(this.queue, e.data);
    }

    socketDisconnected(e) {
        console.log(e);
        this.connected = false;
    }

    tryLastPacket() {
        if (this.lastPacket == null) return;
        if ((Date.now() - this.lastPacket) > 1000) {
            this.socketDisconnected('timeout');
        }
    }

    updateQueue() {
        if (!(!!this.queue && !!this.buffer && !this.buffer.updating)) {
            return;
        }

        this.buffer.appendBuffer(this.queue);
        this.queue = null;
    }

    reduceBuffer() {
        if (!(this.buffer && !this.buffer.updating && this.buffer.buffered && this.buffer.buffered.length > 0)) {
            return;
        }

        try {
            const end = this.buffer.buffered.end(this.buffer.buffered.length - 1);
            const trimTo = Math.max(0, end - 0.01);
            this.buffer.remove(0, trimTo);
        } catch (e) {
            console.warn("Failed to trim buffer:", e);
        }
    }

    syncInterval() {
        if (!(this.audio && this.audio.currentTime && this.buffer && this.buffer.buffered && this.buffer.buffered.length > 0)) {
            return;
        }

        var currentTime = this.audio.currentTime;
        var targetTime = this.buffer.buffered.end(this.buffer.buffered.length - 1);

        if (targetTime > (currentTime + this.maximumAudioLag)) {
            this.audio.currentTime = targetTime;
        }
    }

    concat(buffer1, buffer2) {
        var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
        tmp.set(new Uint8Array(buffer1), 0);
        tmp.set(new Uint8Array(buffer2), buffer1.byteLength);
        return tmp.buffer;
    }
}


const wa = new WebAudio(null);

let intervalStarted = false;

const connect = () => {
    if (typeof MediaSource === "undefined") return;
    if (!wa.connected) {
        wa.start();
    }

    if (wa.connected && !intervalStarted) {
        intervalStarted = true;
        setInterval(connect, 100);
    }
};

addEventListener("keydown", connect, { once: true });
addEventListener("pointerdown", connect, { once: true });
addEventListener("touchstart", connect, { once: true });
