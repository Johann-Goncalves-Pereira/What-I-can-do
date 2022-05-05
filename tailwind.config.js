function withOpacityValue(variable) {
  return ({ opacityValue }) => {
    if (opacityValue === undefined) {
      return `hsl(var(${variable}))`;
    }
    return `hsl(var(${variable}), ${opacityValue})`;
  };
}

module.exports = {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx,elm}"],
  theme: {
    colors: {
      //& Surface
      "surface-0": withOpacityValue("--clr-surface-0"),
      "surface-1": withOpacityValue("--clr-surface-1"),
      "surface-2": withOpacityValue("--clr-surface-2"),
      "surface-3": withOpacityValue("--clr-surface-3"),
      "surface-4": withOpacityValue("--clr-surface-4"),
      "surface-5": withOpacityValue("--clr-surface-5"),
      "surface-6": withOpacityValue("--clr-surface-6"),
      // & Text
      "text-0": withOpacityValue("--clr-text-0"),
      "text-1": withOpacityValue("--clr-text-1"),
      // & Brand
      "brand-0": withOpacityValue("--clr-brand-0"),
      "brand-1": withOpacityValue("--clr-brand-1"),
    },
    extend: {},
  },
  plugins: [],
  corePlugins: {
    preflight: false,
  },
};
