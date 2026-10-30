import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5174,
    strictPort: true,
    proxy: {
      '/api': { target: 'http://https://serenitymsh-production.up.railway.app', changeOrigin: true, secure: false }
    }
  }
})