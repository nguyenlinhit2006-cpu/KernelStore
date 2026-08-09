/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.{rs,html}"],
  theme: {
    extend: {
      colors: {
        bg: {
          primary: "#0a0a0a",
          secondary: "#111111",
          tertiary: "#1a1a1a",
        },
        fg: {
          primary: "#00ff41",
          secondary: "#00d4aa",
          muted: "#6b7280",
        },
      },
    },
  },
  plugins: [],
};
