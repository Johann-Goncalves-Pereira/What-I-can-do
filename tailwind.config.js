function withOpacityValue(variable) {
  return ({ opacityValue }) => {
    if (opacityValue === undefined) {
      return `hsl(var(${variable}))`;
    }
    return `hsl(var(${variable}), ${opacityValue})`;
  };
}

// function variableConstructor(variable, amount) {
//   return ({customProps}) => {
//     for (customProps = 0; customProps < amount; customProps++) {
// return (`${variable}-${customProps}`: withOpacityValue(`surface-${customProps}`));
//   }
// }

module.exports = {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx,elm}"],
  theme: {
    colors: {
      //& Surface
      "surface-0": withOpacityValue("--clr-surface-0"),
      "surface-1": withOpacityValue("--clr-surface-1"),
      "surface-2": withOpacityValue("--clr-surface-2"),
      "surface-3": withOpacityValue("--clr-surface-3"),
      "surface-4": withOpacityValue("--clr-surface-0"),
      "surface-5": withOpacityValue("--clr-surface-0"),
      "surface-6": withOpacityValue("--clr-surface-0"),
      // & Text
      "text-0": withOpacityValue("--clr-text-0"),
      "text-1": withOpacityValue("--clr-text-1"),
      // & Brand
      "brand-0": withOpacityValue("--clr-brand-0"),

    },
    extend: {},
  },
  plugins: [],
  corePlugins: {
    preflight: false,
  },
};
