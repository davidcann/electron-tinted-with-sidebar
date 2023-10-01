import type { Buffer } from "electron";

declare module "electron-tinted-with-sidebar" {
	export function setLayout(
		window: Buffer,
		sidebarWidth: number,
		titlebarHeight: number,
		titlebarMarginRight?: number,
	): void;
	export function setWindowAnimationBehavior(window: Buffer, isDocument: boolean): void;
}
