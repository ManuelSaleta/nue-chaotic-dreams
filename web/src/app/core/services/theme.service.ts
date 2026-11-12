import { DOCUMENT } from '@angular/common';
import {
  computed,
  effect,
  inject,
  Service,
  signal,
  type Signal,
  type WritableSignal,
} from '@angular/core';

/**
 * Supported Material Design 3 color theme modes.
 */
export type ThemeMode = 'dark' | 'light';

/**
 * LocalStorage key used to persist the user's preferred color theme.
 */
export const THEME_STORAGE_KEY = 'nue-chaotic-dreams-theme' as const;

/**
 * Singleton Signal-based service managing Light and Dark Material 3 theme state.
 *
 * @remarks
 * Synchronizes `html.dark-theme` / `html.light-theme` CSS classes, the root
 * `color-scheme` style property, and `localStorage` persistence via an Angular `effect()`.
 */
@Service()
export class ThemeService {
  private readonly document = inject(DOCUMENT);

  /**
   * Active color theme mode (`'dark'` or `'light'`), initialized from `localStorage`
   * and defaulting to `'dark'`.
   */
  public readonly themeMode: WritableSignal<ThemeMode> = signal<ThemeMode>(this.readInitialTheme());

  /**
   * Reactive boolean signal indicating whether the active theme is dark mode.
   */
  public readonly isDark: Signal<boolean> = computed((): boolean => this.themeMode() === 'dark');

  public constructor() {
    effect((): void => {
      const mode = this.themeMode();
      this.applyThemeToDocument(mode);
      this.persistTheme(mode);
    });
  }

  /**
   * Toggles the active theme between `'dark'` and `'light'`.
   */
  public toggleTheme(): void {
    this.themeMode.update((current: ThemeMode): ThemeMode =>
      current === 'dark' ? 'light' : 'dark',
    );
  }

  /**
   * Explicitly sets the active theme mode.
   *
   * @param mode - Target theme mode (`'dark'` or `'light'`).
   */
  public setTheme(mode: ThemeMode): void {
    this.themeMode.set(mode);
  }

  /**
   * Reads the persisted theme from `localStorage`, falling back to `'dark'` when unavailable
   * or invalid.
   *
   * @returns Validated initial theme mode.
   */
  private readInitialTheme(): ThemeMode {
    try {
      const stored = this.document.defaultView?.localStorage?.getItem(THEME_STORAGE_KEY);
      if (stored === 'light' || stored === 'dark') {
        return stored;
      }
    } catch {
      // Ignore storage access errors in restricted/SSR environments.
    }
    return 'dark';
  }

  /**
   * Synchronizes the root `<html>` element classes and `color-scheme` CSS property.
   *
   * @param mode - Active theme mode to apply to the document root.
   */
  private applyThemeToDocument(mode: ThemeMode): void {
    const root = this.document.documentElement;
    if (!root) {
      return;
    }
    root.classList.toggle('dark-theme', mode === 'dark');
    root.classList.toggle('light-theme', mode === 'light');
    root.style.colorScheme = mode;
  }

  /**
   * Persists the active theme mode to `localStorage`.
   *
   * @param mode - Active theme mode to store.
   */
  private persistTheme(mode: ThemeMode): void {
    try {
      this.document.defaultView?.localStorage?.setItem(THEME_STORAGE_KEY, mode);
    } catch {
      // Ignore storage write errors in restricted/private browsing contexts.
    }
  }
}
