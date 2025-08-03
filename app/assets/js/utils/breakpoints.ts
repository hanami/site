type Breakpoint = "sm" | "md" | "lg" | "xl" | "2xl";

// These match Tailwind’s default breakpoints: https://tailwindcss.com/docs/responsive-design
const breakpointMap: Record<Breakpoint, string> = {
  sm: "40rem",
  md: "48rem",
  lg: "64rem",
  xl: "80rem",
  "2xl": "96rem",
};

const breakpointNames = Object.keys(breakpointMap) as Breakpoint[];

function createMediaQueryString(breakpoint: Breakpoint): string {
  const minWidth = breakpointMap[breakpoint];
  return `(width >= ${minWidth})`;
}

/**
 * Returns the current breakpoint match status for all defined breakpoints.
 * Useful for checking which breakpoints are currently active.
 */
export function breakpointMatches(): Record<Breakpoint, boolean> {
  const matches: Record<Breakpoint, boolean> = {
    sm: false,
    md: false,
    lg: false,
    xl: false,
    "2xl": false,
  };

  breakpointNames.forEach((breakpoint: Breakpoint) => {
    const mediaQuery = createMediaQueryString(breakpoint);
    matches[breakpoint] = window.matchMedia(mediaQuery).matches;
  });

  return matches;
}

// TODO: This should really be in Defo
type DefoViewFunction<T = unknown> = {
  update?: (node: HTMLElement, props: T) => void;
  destroy: () => void;
};

/**
 * Higher-order function that wraps a Defo view function to only activate when specified breakpoints match.
 *
 * @param viewFn - The Defo view function to wrap
 * @returns A new view function that respects breakpoint matching
 *
 * @example
 * const responsiveView = breakpointFilter(myViewFn);
 * // Usage: <div data-defo-my-view='{"breakpoints": ["md", "lg"], ...otherProps}'></div>
 */
export function breakpointFilter<T extends object>(
  viewFn: (node: HTMLElement, props: T) => DefoViewFunction,
) {
  return (node: HTMLElement, props: { breakpoints: Breakpoint[] } & T) => {
    const { breakpoints, ...restProps } = props;
    const mediaQueries = breakpoints.map(createMediaQueryString).join(", ");
    const mediaQueryList = window.matchMedia(mediaQueries);

    let activeViewInstance: DefoViewFunction | null = null;
    let mediaQueryListener: ((event: MediaQueryListEvent) => void) | null = null;

    function activateView(): void {
      if (activeViewInstance) return; // Already active

      activeViewInstance = viewFn(node, restProps as T);
    }

    function deactivateView(): void {
      if (!activeViewInstance) return; // Already inactive

      activeViewInstance.destroy();
      activeViewInstance = null;
    }

    function handleMediaQueryChange(event: MediaQueryListEvent): void {
      if (event.matches) {
        activateView();
      } else {
        deactivateView();
      }
    }

    // Set up media query listener
    mediaQueryListener = handleMediaQueryChange;
    mediaQueryList.addEventListener("change", mediaQueryListener);

    // Activate immediately if breakpoint currently matches
    if (mediaQueryList.matches) {
      activateView();
    }

    return {
      update: (updateNode: HTMLElement, updateProps: unknown) => {
        // Only forward update calls to the active view instance
        if (activeViewInstance?.update) {
          activeViewInstance.update(updateNode, updateProps);
        }
      },
      destroy: () => {
        // Clean up media query listener
        if (mediaQueryListener) {
          mediaQueryList.removeEventListener("change", mediaQueryListener);
          mediaQueryListener = null;
        }
        // Deactivate the view if it's currently active
        deactivateView();
      },
    };
  };
}
