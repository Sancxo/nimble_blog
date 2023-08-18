// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    fontFamily: {
      'pixel': ['"Bungee Shade"', 'cursive'],
      'pixel-hair': ['"Bungee Hairline", cursive'],
      'fira': ['"Fira Sans", sans-serif'],
      'fira-code': ['"Fira Code", monospace']
    },
    colors: {
      'black': "#161616",
      'white': '#F8F8FF',
      'future-blue': '#15abbe',
      'ultra-violet': '#6B5B95'
    },
    extend: {
      colors: {
        brand: "#FD4F00",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(function ({ addBase, theme }) {
      addBase({
        'h1': { fontSize: '2em', margin: '0.67em 0', fontWeight: 'bold' },
        'h2': { fontSize: '1.5em', margin: '0.83rem 0', fontWeight: 'bold' },
        'h3': { fontSize: '1.17em', margin: `1em 0`, fontWeight: 'bold' },
        'p': { margin: '1em 0' },
        'pre': {
          margin: '1em 0 2rem', padding: "1rem 2.5rem 1rem 1rem", fontSize: '.833rem', background: '#272822', color: theme("colors.black")
        },
        'code': { padding: '.125rem .25rem', fontSize: '.833rem', background: '#272822', color: '#f8f8f2' },
        'img': { margin: 'auto' },
        'blockquote': { margin: '1em 40px' },
        'dl': { margin: '1em 0' },
        'dd': { margin: '0 0 0 40px' }
      })
    }),
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
