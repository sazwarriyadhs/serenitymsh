/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        gold: { 50:'#FBF6E9',100:'#F5E9C7',200:'#EBD49A',300:'#DFBC6B',400:'#D4AF37',500:'#C9A961',600:'#B8860B',700:'#946A08',800:'#6E4E06',900:'#4A3404' },
        ink: { 900:'#0A0E1A',800:'#111624',700:'#1A2033' },
        cream: { 50:'#FDFBF7',100:'#F8F5F0',200:'#EFE9DF' },
      },
      fontFamily: {
        serif: ['"Cormorant Garamond"', 'Georgia', 'serif'],
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      keyframes: {
        fadeUp: { '0%':{opacity:0,transform:'translateY(24px)'}, '100%':{opacity:1,transform:'translateY(0)'} },
        float: { '0%,100%':{transform:'translateY(0)'}, '50%':{transform:'translateY(-10px)'} },
      },
      animation: { 'fade-up':'fadeUp 0.8s ease-out forwards', 'float':'float 6s ease-in-out infinite' },
    },
  },
  plugins: [],
}