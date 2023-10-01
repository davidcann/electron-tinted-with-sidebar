const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("electronAPI", {
	send: (channel, command, data) => {
		let validChannels = ["toMain"];
		if (validChannels.includes(channel)) {
			ipcRenderer.send(channel, command, data);
		}
	},
	receive: (channel, func) => {
		let validChannels = ["fromMain"];
		if (validChannels.includes(channel)) {
			// Deliberately strip event as it includes `sender`
			ipcRenderer.on(channel, (event, ...args) => func(...args));
		}
	},
});
