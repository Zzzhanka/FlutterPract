import { useEffect, useState } from "react";
import { supabase } from "../supabase";

export default function Levels() {
  const [levels, setLevels] = useState([]);
  const [showModal, setShowModal] = useState(false);

  const [gridSize, setGridSize] = useState(3);
  const [shuffleMoves, setShuffleMoves] = useState(20);
  const [imageFile, setImageFile] = useState(null);

  useEffect(() => {
    fetchLevels();
  }, []);

  async function fetchLevels() {
    const { data } = await supabase.from("levels").select("*");
    setLevels(data);
  }

  async function handleAddLevel() {
    if (!imageFile) return alert("Загрузите изображение");

    const fileName = `level_${Date.now()}.png`;

    // 1️⃣ Загружаем в storage
    const { error: uploadError } = await supabase.storage
      .from("levels")
      .upload(fileName, imageFile);

    if (uploadError) {
      alert("Ошибка загрузки");
      return;
    }

    // 2️⃣ Получаем public URL
    const { data } = supabase.storage
      .from("levels")
      .getPublicUrl(fileName);

    const imageUrl = data.publicUrl;

    // 3️⃣ Добавляем запись в БД
    await supabase.from("levels").insert({
      title: "level", // можно потом обновить после id
      image_path: imageUrl,
      grid_size: gridSize,
      shuffle_moves: shuffleMoves,
      page: 1
    });

    setShowModal(false);
    fetchLevels();
  }

  return (
    <div>
      <h2>Уровни</h2>

      <button onClick={() => setShowModal(true)}>
        Добавить уровень
      </button>

      <ul>
        {levels.map(level => (
          <li key={level.id}>
            #{level.id} | {level.grid_size}x{level.grid_size}
          </li>
        ))}
      </ul>

      {showModal && (
        <div style={modalStyle}>
          <div style={modalContent}>
            <h3>Новый уровень</h3>

            <label>Размер сетки:</label>
            <input
              type="number"
              value={gridSize}
              onChange={e => setGridSize(e.target.value)}
            />

            <label>Перемешивание:</label>
            <input
              type="number"
              value={shuffleMoves}
              onChange={e => setShuffleMoves(e.target.value)}
            />

            <label>Картинка:</label>
            <input
              type="file"
              onChange={e => setImageFile(e.target.files[0])}
            />

            <br /><br />
            <button onClick={handleAddLevel}>Сохранить</button>
            <button onClick={() => setShowModal(false)}>Отмена</button>
          </div>
        </div>
      )}
    </div>
  );
}

const modalStyle = {
  position: "fixed",
  top: 0,
  left: 0,
  width: "100%",
  height: "100%",
  background: "rgba(0,0,0,0.5)",
  display: "flex",
  justifyContent: "center",
  alignItems: "center"
};

const modalContent = {
  background: "white",
  padding: 30,
  borderRadius: 10,
  display: "flex",
  flexDirection: "column",
  gap: 10
};
