import proxy from "./proxy.js";
import ffmpeg from "./ffmpeg.js";
import { closeResponse } from "./shared.js";
import { internalStream } from "./internal.js";

export default async function(res, streamInfo) {
    try {
        switch (streamInfo.type) {
            // DIRECT MODE: Server engine (ffmpeg/proxy) ko bypass karta hai 
            // aur client ko direct CDN URL bhej deta hai.
            case "direct":
                return res.status(200).json({
                    url: Array.isArray(streamInfo.urls) ? streamInfo.urls[0] : streamInfo.urls,
                    filename: streamInfo.filename,
                    type: "direct"
                });

            case "proxy":
                return await proxy(streamInfo, res);

            case "internal":
                return await internalStream(streamInfo.data, res);

            case "merge":
            case "remux":
            case "mute":
                return await ffmpeg.remux(streamInfo, res);

            case "audio":
                return await ffmpeg.convertAudio(streamInfo, res);

            case "gif":
                return await ffmpeg.convertGif(streamInfo, res);
        }

        closeResponse(res);
    } catch {
        closeResponse(res);
    }
}
