export interface Framework {
  name: string
  slug: string
  color: string
}

export const frameworks: Framework[] = [
  { name: 'React', slug: 'react', color: '61DAFB' },
  { name: 'Vue', slug: 'vuedotjs', color: '4FC08D' },
  { name: 'Angular', slug: 'angular', color: 'DD0031' },
  { name: 'Svelte', slug: 'svelte', color: 'FF3E00' },
  { name: 'Next.js', slug: 'nextdotjs', color: 'ffffff' },
  { name: 'Nuxt', slug: 'nuxt', color: '00DC82' },
  { name: 'Remix', slug: 'remix', color: 'ffffff' },
  { name: 'Astro', slug: 'astro', color: 'FF5D01' },
  { name: 'Vite', slug: 'vite', color: '646CFF' },
  { name: 'Webpack', slug: 'webpack', color: '8DD6F9' },
  { name: 'Node.js', slug: 'nodedotjs', color: '339933' },
  { name: 'Deno', slug: 'deno', color: 'ffffff' },
  { name: 'Bun', slug: 'bun', color: 'FBF0DF' },
  { name: 'Express', slug: 'express', color: 'ffffff' },
  { name: 'Fastify', slug: 'fastify', color: 'ffffff' },
  { name: 'NestJS', slug: 'nestjs', color: 'E0234E' },
  { name: 'Django', slug: 'django', color: '44B78B' },
  { name: 'Flask', slug: 'flask', color: 'ffffff' },
  { name: 'FastAPI', slug: 'fastapi', color: '009688' },
  { name: 'Rails', slug: 'rubyonrails', color: 'CC0000' },
  { name: 'Laravel', slug: 'laravel', color: 'FF2D20' },
  { name: 'Spring Boot', slug: 'springboot', color: '6DB33F' },
  { name: 'Docker', slug: 'docker', color: '2496ED' },
  { name: 'Nginx', slug: 'nginx', color: '009639' },
  { name: 'SvelteKit', slug: 'svelte', color: 'FF3E00' },
  { name: 'Solid', slug: 'solid', color: '2C4F7C' },
  { name: 'Qwik', slug: 'qwik', color: 'AC7EF4' },
  { name: 'Hono', slug: 'hono', color: 'E36002' },
  { name: 'Rollup', slug: 'rollupdotjs', color: 'EC4A3F' },
  { name: 'Storybook', slug: 'storybook', color: 'FF4785' },
  { name: 'Expo', slug: 'expo', color: 'ffffff' },
]

export const frameworksRow1 = frameworks.slice(0, 16)
export const frameworksRow2 = frameworks.slice(16)
