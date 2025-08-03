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

function createMediaQueryString(breakpoint: Breakpoint) {
  const minWidth = breakpointMap[breakpoint];
  return `(width >= ${minWidth})`;
}

export function breakpointMatches() {
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
type ViewFnReturnValue = {
  update?: (node: HTMLElement, props: unknown) => void;
  destroy: () => void;
};

export function breakpointFilter<T extends object>(
  viewFn: (node: HTMLElement, props: T) => ViewFnReturnValue,
) {
  let returnRef: ViewFnReturnValue & { originalDestroy: ViewFnReturnValue["destroy"] } = {
    destroy: () => {},
    originalDestroy: () => {},
  };

  const destroy = () => returnRef.destroy();
  const update: ViewFnReturnValue["update"] = (...args) =>
    returnRef.update ? returnRef.update(...args) : undefined;

  return (node: HTMLElement, props: { breakpoints: Breakpoint[] } & T) => {
    const { breakpoints, ...rest } = props;
    const mediaQueries = breakpoints.map(createMediaQueryString).join(", ");
    const mediaQueryList = window.matchMedia(mediaQueries);

    if (mediaQueryList.matches) {
      onMatch();
    }

    function onMatch() {
      const returnValue = viewFn(node, rest as T);

      returnRef = {
        ...(returnValue.update ? { update: returnValue.update } : {}),
        originalDestroy: returnValue.destroy ?? returnRef,
        destroy: () => {
          // Remove the listener
          mediaQueryList.removeEventListener("change", onChange);
          // Call the destroy function of the bound viewFn
          returnValue.destroy();
        },
      };
    }

    function onChange(event: MediaQueryListEvent) {
      if (event.matches) {
        onMatch();
      } else {
        returnRef.originalDestroy();
      }
    }

    mediaQueryList.addEventListener("change", onChange);

    return {
      destroy,
      update,
    };
  };
}
