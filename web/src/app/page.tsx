export default function Home() {
  return (
    <div className="min-h-screen bg-[#0A0A0A] text-white flex flex-col">
      {/* Header */}
      <header className="border-b border-[#2A2A2A] px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#00C853] flex items-center justify-center font-bold text-black text-lg">
            eF
          </div>
          <span className="text-xl font-bold tracking-tight">eFoot Arena</span>
        </div>
        <nav className="hidden md:flex items-center gap-8 text-sm text-zinc-400">
          <a href="#features" className="hover:text-white transition">
            Fonctionnalités
          </a>
          <a href="#about" className="hover:text-white transition">
            À propos
          </a>
          <a
            href="#"
            className="bg-[#00C853] text-black px-5 py-2 rounded-lg font-semibold hover:bg-[#00A844] transition"
          >
            Télécharger l&apos;app
          </a>
        </nav>
      </header>

      {/* Hero */}
      <main className="flex-1 flex flex-col items-center justify-center px-6 text-center">
        <div className="max-w-3xl space-y-8">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#1A1A1A] border border-[#2A2A2A] text-sm text-[#00C853]">
            <span className="w-2 h-2 rounded-full bg-[#00C853] animate-pulse" />
            Bientôt disponible en Afrique
          </div>

          <h1 className="text-5xl md:text-7xl font-bold tracking-tight leading-tight">
            Compete.
            <br />
            <span className="text-[#00C853]">Dominate.</span>
            <br />
            Rise.
          </h1>

          <p className="text-lg md:text-xl text-zinc-400 max-w-xl mx-auto leading-relaxed">
            La plateforme compétitive eFootball Mobile. Crée ton profil, rejoins
            une équipe, lance des défis et grimpe dans les classements.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
            <a
              href="#"
              className="w-full sm:w-auto px-8 py-3.5 bg-[#00C853] text-black font-semibold rounded-xl hover:bg-[#00A844] transition"
            >
              Rejoindre la waitlist
            </a>
            <a
              href="#features"
              className="w-full sm:w-auto px-8 py-3.5 border border-[#2A2A2A] rounded-xl hover:border-[#00C853] transition"
            >
              Découvrir les features
            </a>
          </div>
        </div>
      </main>

      {/* Features preview */}
      <section id="features" className="border-t border-[#2A2A2A] px-6 py-20">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">
            Tout pour la compétition
          </h2>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                title: "Défis 1v1",
                desc: "Challenge n’importe quel joueur et prouve ta supériorité.",
              },
              {
                title: "Équipes & Clan Wars",
                desc: "Crée ou rejoins une équipe et domine les battles.",
              },
              {
                title: "Classements",
                desc: "Grimpe du Bronze au Legendary dans ta région et au mondial.",
              },
              {
                title: "Stats avancées",
                desc: "Winrate, séries, historique complet de tes performances.",
              },
              {
                title: "Tournois",
                desc: "Participe à des compétitions officielles et gagne des trophées.",
              },
              {
                title: "Communauté",
                desc: "Chat, highlights, et une communauté 100% eFootball.",
              },
            ].map((f) => (
              <div
                key={f.title}
                className="p-6 rounded-2xl bg-[#141414] border border-[#2A2A2A] hover:border-[#00C853]/40 transition"
              >
                <h3 className="text-lg font-semibold mb-2 text-[#00C853]">
                  {f.title}
                </h3>
                <p className="text-zinc-400 text-sm leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-[#2A2A2A] px-6 py-8 text-center text-sm text-zinc-500">
        <p>© 2026 eFoot Arena — Compete. Dominate. Rise.</p>
      </footer>
    </div>
  );
}
