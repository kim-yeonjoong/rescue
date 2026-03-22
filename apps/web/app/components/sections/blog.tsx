import { BlurFade } from '@/components/magicui/blur-fade'

const POSTS = [
  {
    title: 'Introducing Rescue',
    date: 'March 1, 2025',
    ago: '(8mo ago)',
    summary: 'Meet Rescue, the macOS menu bar app that helps you find and manage forgotten dev processes.',
    gradient: 'from-violet-900/60 via-violet-800/30 to-[#111111]',
    mockLines: [
      { id: 'a1', text: '# Rescue' },
      { id: 'a2', text: '> Find forgotten' },
      { id: 'a3', text: '> dev servers' },
      { id: 'a4', text: '' },
      { id: 'a5', text: '$ brew install rescue' },
    ],
  },
  {
    title: 'Why I Built Rescue',
    date: 'February 15, 2025',
    ago: '(9mo ago)',
    summary: 'I was tired of forgotten dev servers hogging ports. So I built a tool to fix that once and for all.',
    gradient: 'from-blue-900/60 via-blue-800/30 to-[#111111]',
    mockLines: [
      { id: 'b1', text: ':3000 → Next.js' },
      { id: 'b2', text: ':8080 → Python' },
      { id: 'b3', text: ':5432 → PG' },
      { id: 'b4', text: ':6379 → Redis' },
      { id: 'b5', text: '' },
    ],
  },
  {
    title: 'How Rescue Detects Frameworks',
    date: 'January 30, 2025',
    ago: '(10mo ago)',
    summary: 'A deep dive into how Rescue identifies Node.js, Python, Ruby, and other dev servers from process metadata.',
    gradient: 'from-green-900/60 via-green-800/30 to-[#111111]',
    mockLines: [
      { id: 'c1', text: '// framework detection' },
      { id: 'c2', text: 'if (cmd.includes(' },
      { id: 'c3', text: '  "node"' },
      { id: 'c4', text: ')) return "Node.js"' },
    ],
  },
]

export default function Blog() {
  return (
    <section>
      <div className="grid grid-cols-1 divide-y divide-white/10 border-t border-white/10 sm:grid-cols-3 sm:divide-x sm:divide-y-0">
          {POSTS.map((post, i) => (
            <BlurFade key={post.title} delay={0.05 * i} inView>
              <div className="flex flex-col cursor-pointer hover:bg-white/[0.02] transition-colors duration-200">
                {/* Blog post image mockup */}
                <div className={`h-44 bg-gradient-to-b ${post.gradient} overflow-hidden border-b border-white/10`}>
                  <div className="h-full p-5 font-mono text-[10px] text-white/30 leading-relaxed">
                    {post.mockLines.map((line) => (
                      <div key={line.id}>{line.text || <span>&nbsp;</span>}</div>
                    ))}
                  </div>
                </div>

                <div className="flex flex-1 flex-col p-6">
                  <div className="flex items-center gap-2 text-[10px] text-white/30">
                    <time>{post.date}</time>
                    <span>{post.ago}</span>
                  </div>
                  <h3 className="mt-2 text-sm font-semibold text-white leading-snug">
                    {post.title}
                  </h3>
                  <p className="mt-2 flex-1 text-xs text-white/50 leading-relaxed">
                    {post.summary}
                  </p>
                  <div className="mt-4">
                    <span className="text-xs text-violet-400 hover:text-violet-300 transition-colors">
                      Read more &gt;
                    </span>
                  </div>
                </div>
              </div>
            </BlurFade>
          ))}
        </div>
    </section>
  )
}
