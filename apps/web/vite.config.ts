import { fileURLToPath, URL } from 'node:url'

import tailwindcss from '@tailwindcss/vite'
import { tanstackRouter } from '@tanstack/router-plugin/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'


export default defineConfig({
  plugins: [
    tanstackRouter({
      routesDirectory: './app/routes',
      generatedRouteTree: './app/routeTree.gen.ts',
    }),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app', import.meta.url)),
    },
  },
})
