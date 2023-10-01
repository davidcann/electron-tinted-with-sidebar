const titlebarHeight = 52;
const defaultSidebarWidth = 200;
let sidebarWidth = defaultSidebarWidth;
let sidebar;
let divider;
let main;
let titlebar;
let system;
let light;
let dark;

window.addEventListener("DOMContentLoaded", () => {
	sidebar = document.getElementById("sidebar");
	divider = document.getElementById("dividerContainer");
	main = document.getElementById("main");
	titlebar = document.getElementById("titlebar");
	system = document.getElementById("system");
	light = document.getElementById("light");
	dark = document.getElementById("dark");
	updateLayout();

	let dragging = false;
	divider.addEventListener("pointerdown", (e) => {
		dragging = true;
		e.target.setPointerCapture(e.pointerId);
	});
	divider.addEventListener("pointermove", (e) => {
		if (dragging) {
			sidebarWidth = Math.max(100, Math.min(500, sidebarWidth + Math.round(e.movementX)));
			updateLayout();
		}
	});
	divider.addEventListener("pointerup", (e) => {
		dragging = false;
		e.target.releasePointerCapture(e.pointerId);
	});
	divider.addEventListener("dblclick", (e) => {
		sidebarWidth = defaultSidebarWidth;
		updateLayout();
	});

	if (navigator.platform.toLowerCase().indexOf("mac") == -1) {
		document.body.classList.add("solidBackground");
	}
});

window.addEventListener("blur", () => {
	document.body.classList.add("windowInactive");
});

window.addEventListener("focus", () => {
	document.body.classList.remove("windowInactive");
});

function updateLayout() {
	sidebar.style.width = `${sidebarWidth}px`;
	divider.style.left = `${sidebarWidth - 2}px`;
	main.style.left = `${sidebarWidth + 0.5}px`;
	titlebar.style.height = `${titlebarHeight}px`;
	window.electronAPI.send("toMain", "setWindowLayout", { sidebarWidth, titlebarHeight });
}

function setTheme(themeSource) {
	window.electronAPI.send("toMain", "setNativeTheme", { themeSource });
	if (themeSource == "system") {
		system.classList.add("selected");
		light.classList.remove("selected");
		dark.classList.remove("selected");
	} else if (themeSource == "light") {
		system.classList.remove("selected");
		light.classList.add("selected");
		dark.classList.remove("selected");
	} else if (themeSource == "dark") {
		system.classList.remove("selected");
		light.classList.remove("selected");
		dark.classList.add("selected");
	}
}
