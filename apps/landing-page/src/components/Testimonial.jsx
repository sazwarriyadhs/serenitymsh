export default function Testimonial() {
  return (
    <section className="py-24 px-6 bg-ink-900 border-y border-gold-400/20 text-center relative overflow-hidden">
      <div className="absolute inset-0 arch-motif opacity-10 pointer-events-none" />
      <div className="max-w-4xl mx-auto relative z-10">
        <div className="text-gold-400 text-5xl font-serif leading-none mb-6">"</div>
        <p className="font-serif text-2xl md:text-4xl text-cream-50 leading-tight italic">
          The perfect blend of academic prestige and modern luxury. Our international conference was executed flawlessly.
        </p>
        <div className="mt-8 flex flex-col items-center">
          <div className="w-12 h-px bg-gold-400/50 mb-4" />
          <p className="text-gold-300 text-sm tracking-widest uppercase">Conference Organizer</p>
          <p className="text-cream-100/50 text-xs mt-1">Global Agricultural Summit</p>
        </div>
      </div>
    </section>
  )
}