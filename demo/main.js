const { app, BrowserWindow, nativeTheme } = require("electron");
const tint = require("../main.js");

function createWindow() {
	const mainWindow = new BrowserWindow({
		height: 500,
		minHeight: 400,
		minWidth: 500,
		width: 900,
		backgroundColor: "#00000000",
		show: false,
		titleBarStyle: "hidden",
		vibrancy: "sidebar",
		webPreferences: {
			preload: __dirname + "/preload.js",
		},
	});
	tint.setWindowAnimationBehavior(mainWindow.getNativeWindowHandle(), true);
	tint.setLayout(mainWindow.getNativeWindowHandle(), 200, 52);

	mainWindow.webContents.loadFile("index.html");
	mainWindow.setWindowButtonPosition({ x: 19, y: 18 });

	mainWindow.on("ready-to-show", () => {
		mainWindow.show();
	});

	mainWindow.webContents.ipc.on("toMain", (event, command, data) => {
		if (command === "setLayout") {
			tint.setLayout(mainWindow.getNativeWindowHandle(), data.sidebarWidth, data.titlebarHeight);
		} else if (command === "setNativeTheme") {
			nativeTheme.themeSource = data.themeSource;
		}
	});
}

app.whenReady().then(() => createWindow());
app.on("window-all-closed", () => app.quit());
