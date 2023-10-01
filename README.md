# electron-tinted-with-sidebar

> Create a native wallpaper-tinted window with a sidebar in [Electron](https://electronjs.org/) on macOS

Electron BrowserWindow supports only one [`vibrancy` mode](https://www.electronjs.org/docs/latest/api/browser-window#winsetvibrancytype-macos) at a time, but standard macOS apps commonly have both a sidebar and main content area (often titlebar and inspector) that should be tinted based on the wallpaper on the user's desktop (macOS System Settings > Appearance > Allow wallpaper tinting in windows). The `setLayout` function adds [NSVisualEffectView](https://developer.apple.com/documentation/appkit/nsvisualeffectview?language=objc)s with the correct materials.

The `setWindowAnimationBehavior`` function enables you to configure a window to have the "zoom up" entrance animation.

[See demo code](demo) for additional styling in HTML, such as the separator lines and subtle sidebar inner shadow. Dark mode is supported through macOS System Settings or [nativeTheme.themeSource](https://www.electronjs.org/docs/latest/api/native-theme#nativethemethemesource).

https://github.com/davidcann/electron-tinted-with-sidebar/assets/23272/7cf04b0a-ed52-4931-ab1a-18184aa4c7e3

## Installing

    npm install electron-tinted-with-sidebar

## API

**setLayout(nativeWindowHandle, sidebarWidth, titlebarHeight[, titlebarMarginRight])** (macOS only)

- `nativeWindowHandle` Buffer (NSView\*) from [BrowserWindow's win.getNativeWindowHandle()](https://www.electronjs.org/docs/latest/api/browser-window#wingetnativewindowhandle)
- `sidebarWidth` integer
- `titlebarHeight` integer
- `titlebarMarginRight` integer (optional) - This is useful to expose the background for a full-height inspector. Defaults to `0`.

**setWindowAnimationBehavior(nativeWindowHandle, isDocument)** (macOS only)

- `nativeWindowHandle` Buffer (NSView\*) from [BrowserWindow's win.getNativeWindowHandle()](https://www.electronjs.org/docs/latest/api/browser-window#wingetnativewindowhandle)
- `isDocument` bool – `true` sets the NSWindow `animationBehavior` to `NSWindowAnimationBehaviorDocumentWindow`, which animates the window (zoom up) on entrance.

Note that you must call this function before the window is shown or it will have no effect.

## Usage

In main process:

    const { BrowserWindow } = require("electron");
    const tint = require("electron-tinted-with-sidebar");

    function createWindow() {
    	const mainWindow = new BrowserWindow({
    		height: 500,
    		width: 800,
    		backgroundColor: "#00000000",
    		titleBarStyle: "hidden",
    		vibrancy: "sidebar",
    	});
    	tint.setWindowAnimationBehavior(mainWindow.getNativeWindowHandle(), true);
    	tint.setLayout(mainWindow.getNativeWindowHandle(), 200, 52);
    	mainWindow.webContents.loadFile("index.html");
    }

    app.whenReady().then(() => createWindow());

## How to Run Demo

After cloning this repository, run:

    npm install
    npm rebuild && npm start --prefix demo/

## License

MIT License

## Acknowledgements

- [electron-window-rotator](https://github.com/antonfisher/electron-window-rotator) – a great example project
