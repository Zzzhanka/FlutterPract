import { useEffect, useState } from "react";
import { supabase } from "../supabase";

export default function Daily() {
  const [levels, setLevels] = useState([]);
  const [achievements, setAchievements] = useState([]);
  const [selectedLevel, setSelectedLevel] = useState("");
  const [selectedAch, setSelectedAch] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      const { data: lvls } = await supabase.from("levels").select("id, title");
      setLevels(lvls || []);

      const { data: achs } = await supabase
        .from("achievements")
        .select("id, title");
      setAchievements(achs || []);
    };
    fetchData();
  }, []);

  const saveDailyChallenge = async () => {
    if (!selectedLevel && !selectedAch) {
      alert("Выберите уровень или ачивку!");
      return;
    }

    const payload = {
      challenge_date: new Date().toISOString().split("T")[0],
      challenge_type: selectedLevel ? "level" : "achievement",
      challenge_id: selectedLevel || selectedAch,
    };

    const { error } = await supabase.from("daily_challenges").upsert(payload);

    if (error) {
      alert("Ошибка: " + error.message);
    } else {
      alert("Ежедневное испытание сохранено!");
    }
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
      <h2>Выбрать Daily Challenge</h2>

      <div style={{ display: "flex", gap: 20 }}>
        <div style={{ flex: 1 }}>
          <h3>Выберите уровень</h3>
          <select
            style={{ width: "100%", padding: 10 }}
            value={selectedLevel}
            onChange={(e) => setSelectedLevel(e.target.value)}
          >
            <option value="">-- Уровень не выбран --</option>
            {levels.map((lvl) => (
              <option key={lvl.id} value={lvl.id}>
                {lvl.title}
              </option>
            ))}
          </select>
        </div>

        <div style={{ flex: 1 }}>
          <h3>Выберите ачивку</h3>
          <select
            style={{ width: "100%", padding: 10 }}
            value={selectedAch}
            onChange={(e) => setSelectedAch(e.target.value)}
          >
            <option value="">-- Ачивка не выбрана --</option>
            {achievements.map((ach) => (
              <option key={ach.id} value={ach.id}>
                {ach.title}
              </option>
            ))}
          </select>
        </div>
      </div>

      <button
        style={{
          padding: "12px 24px",
          backgroundColor: "#4a90e2",
          color: "#fff",
          border: "none",
          borderRadius: 8,
          cursor: "pointer",
        }}
        onClick={saveDailyChallenge}
      >
        Сохранить
      </button>
    </div>
  );
}