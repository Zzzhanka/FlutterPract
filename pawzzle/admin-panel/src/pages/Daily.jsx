import { useEffect, useState } from "react";
import { supabase } from "../supabase";

export default function Daily() {
  const [levels, setLevels] = useState([]);
  const [achievements, setAchievements] = useState([]);
  const [type, setType] = useState("level");
  const [selected, setSelected] = useState("");

  useEffect(() => {
    supabase.from("levels").select("*").then(res => setLevels(res.data));
    supabase.from("achievements").select("*").then(res => setAchievements(res.data));
  }, []);

  async function createChallenge() {
  if (!selected) {
    alert("Выберите уровень");
    return;
  }

  const { data, error } = await supabase
    .from("daily_challenges")
    .insert({
      level_id: Number(selected),
      challenge_date: new Date().toISOString().split("T")[0],
      is_active: true
    })
    .select();

  if (error) {
    console.error(error);
    alert("Ошибка: " + error.message);
  } else {
    alert("Уровень дня назначен!");
  }
}

  return (
    <div>,     
      <h2>Ежедневное испытание</h2>

      <select onChange={e => setType(e.target.value)}>
        <option value="level">Уровень</option>
        <option value="achievement">Ачивка</option>
      </select>

      <select onChange={e => setSelected(e.target.value)}>
        <option>Выберите</option>

        {type === "level" &&
          levels.map(l => (
            <option key={l.id} value={l.id}>
              Уровень #{l.id}
            </option>
          ))}

        {type === "achievement" &&
          achievements.map(a => (
            <option key={a.id} value={a.id}>
              {a.title}
            </option>
          ))}
      </select>

      <button onClick={createChallenge}>
        Назначить
      </button>
    </div>
  );
}
