export default function Home() {
  return (
    <main style={{ padding: "40px", fontFamily: "sans-serif" }}>
      <h1>ANC Demo</h1>

      <div style={{ marginBottom: "24px" }}>
        <h2>Noisy</h2>
        <audio controls src="/audio/noisy.wav"></audio>
      </div>

      <div>
        <h2>Enhanced</h2>
        <audio controls src="/audio/enhanced.wav"></audio>
      </div>
    </main>
  );
}