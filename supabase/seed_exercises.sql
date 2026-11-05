-- ==============================================================================
-- Seed: 17 Exercises from assets/data/exercises.json
-- Database: Supabase (PostgreSQL)
-- ==============================================================================

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'push_up', 'Push Up', 'Push Up', 'push', 'main', 'intermediate', 'reps',
    '[{"id":"Dada","en":"Chest"},{"id":"Triceps","en":"Triceps"},{"id":"Bahu depan","en":"Anterior Deltoids"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Punggung bawah","en":"Lower Back"},{"id":"Bokong","en":"Glutes"},{"id":"Serratus","en":"Serratus Anterior"}]'::jsonb, '["Posisikan tangan sedikit lebih lebar dari bahu, telapak tangan rata di lantai.","Luruskan tubuh dari kepala, punggung, bokong, hingga tumit dalam satu garis lurus.","Kunci otot perut dan bokong agar pinggang tidak melorot.","Turunkan badan secara terkontrol dengan siku membentuk sudut sekitar 45 derajat hingga dada hampir menyentuh lantai.","Dorong lantai kuat-kuat hingga lengan lurus kembali ke posisi awal."]'::jsonb, '["Place hands slightly wider than shoulder-width apart, palms flat on the floor.","Keep your body in a straight line from head to heels.","Engage your core and glutes to prevent your lower back from sagging.","Lower your body under control with elbows at about 45 degrees until chest nearly touches the floor.","Push through the floor firmly to return to the starting plank position."]'::jsonb,
    '["Pinggang melorot ke bawah atau bokong terlalu menungging tinggi.","Siku membuka terlalu lebar ke samping (90 derajat / bentuk huruf T) yang membebani bahu.","Rentang gerak setengah (tidak turun cukup rendah atau tidak mengunci di atas)."]'::jsonb, '["Sagging lower back or pushing the hips too high.","Flaring elbows out to 90 degrees (T-shape), placing excessive stress on shoulders.","Doing half reps without full range of motion."]'::jsonb, 'Tarik napas saat menurunkan badan, hembuskan napas saat mendorong naik.', 'Inhale as you lower your body, exhale as you push back up.',
    'assets/images/exercises/push_up_start.webp', 'assets/images/exercises/push_up_end.webp', 'assets/images/exercises/push_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'diamond_push_up', 'Diamond Push Up', 'Diamond Push Up', 'push', 'main', 'advanced', 'reps',
    '[{"id":"Triceps","en":"Triceps"},{"id":"Dada tengah","en":"Inner/Center Chest"},{"id":"Bahu depan","en":"Anterior Deltoids"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Bokong","en":"Glutes"},{"id":"Serratus","en":"Serratus Anterior"}]'::jsonb, '["Ambil posisi plank tinggi dengan kedua tangan dirapatkan tepat di bawah dada.","Satukan ibu jari dan jari telunjuk hingga membentuk pola berlian/segitiga.","Jaga tubuh tetap lurus dari kepala hingga tumit.","Turunkan dada perlahan mendekati tangan berlian dengan siku tetap rapat dekat samping tubuh.","Tekan lantai kembali ke atas sambil mengontraksikan triceps secara maksimal."]'::jsonb, '["Assume a high plank position with hands close together directly beneath your chest.","Join your thumbs and index fingers to form a diamond/triangle shape.","Maintain a straight line from head to heels.","Lower your chest down towards the diamond shape, keeping elbows tucked close to your torso.","Push back up to the starting position, fully contracting your triceps."]'::jsonb,
    '["Posisi tangan terlalu jauh di depan wajah (seharusnya tepat di bawah dada).","Siku melebar ke luar yang memicu rasa tidak nyaman pada pergelangan tangan dan siku."]'::jsonb, '["Placing hands too far ahead of chest near the face.","Flaring elbows excessively wide which stresses wrists and elbows."]'::jsonb, 'Tarik napas saat turun, hembuskan napas kuat saat mendorong naik.', 'Inhale as you lower, exhale forcefully as you press up.',
    'assets/images/exercises/diamond_push_up_start.webp', 'assets/images/exercises/diamond_push_up_end.webp', 'assets/images/exercises/diamond_push_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'incline_push_up', 'Incline Push Up', 'Incline Push Up', 'push', 'main', 'beginner', 'reps',
    '[{"id":"Dada bawah","en":"Lower Chest"},{"id":"Triceps","en":"Triceps"},{"id":"Bahu depan","en":"Anterior Deltoids"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Punggung bawah","en":"Lower Back"}]'::jsonb, '["Letakkan kedua tangan di atas permukaan yang lebih tinggi (meja stabil, kursi kokoh, atau undakan ranjang).","Mundurkan kaki hingga tubuh membentuk garis miring yang lurus dari kepala ke tumit.","Turunkan dada menuju tepi permukaan tumpuan secara terkontrol.","Dorong kembali hingga lengan lurus tanpa mengunci sendi siku secara berlebihan."]'::jsonb, '["Place hands on an elevated, stable surface (sturdy bench, table, or bed edge).","Step feet back until your body forms a straight incline plank.","Lower your chest towards the edge of the elevated surface under control.","Push back up until arms are extended without hyper-extending elbows."]'::jsonb,
    '["Memakai permukaan tumpuan yang goyah atau licin.","Membungkukkan leher ke depan untuk mengejar permukaan."]'::jsonb, '["Using an unstable or slippery elevated surface.","Reaching forward with the neck instead of bringing the chest to the edge."]'::jsonb, 'Tarik napas saat merendahkan badan, hembuskan napas saat mendorong menjauh.', 'Inhale on descent, exhale on press.',
    'assets/images/exercises/incline_push_up_start.webp', 'assets/images/exercises/incline_push_up_end.webp', 'assets/images/exercises/incline_push_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'knee_push_up', 'Knee Push Up', 'Knee Push Up', 'push', 'main', 'beginner', 'reps',
    '[{"id":"Dada","en":"Chest"},{"id":"Triceps","en":"Triceps"},{"id":"Bahu depan","en":"Anterior Deltoids"}]'::jsonb, '{"id":"Perut","en":"Core"}'::jsonb, '["Mulai dengan posisi merangkak, lalu mundurkan lutut sedikit ke belakang hingga tubuh lurus dari kepala ke lutut.","Letakkan tangan selebar bahu di lantai.","Turunkan dada mendekati lantai dengan menjaga garis lurus dari bahu hingga lutut.","Dorong lantai kembali ke atas sampai lengan lurus."]'::jsonb, '["Start on hands and knees, shift knees back slightly until body forms a straight line from head to knees.","Place hands shoulder-width apart flat on the mat.","Lower chest toward the ground, keeping core tight and hips aligned.","Push the floor away to return to the starting position."]'::jsonb,
    '["Bokong tetap menekuk ke atas seperti merangkak (harus lurus dari kepala ke lutut).","Menjatuhkan panggul ke lantai mendahului dada."]'::jsonb, '["Leaving hips folded up in a tabletop posture instead of an angled plank.","Dropping the pelvis first rather than the chest."]'::jsonb, 'Tarik napas saat turun, hembuskan napas saat mendorong naik.', 'Inhale down, exhale up.',
    'assets/images/exercises/knee_push_up_start.webp', 'assets/images/exercises/knee_push_up_end.webp', 'assets/images/exercises/knee_push_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'decline_push_up', 'Decline Push Up', 'Decline Push Up', 'push', 'main', 'advanced', 'reps',
    '[{"id":"Dada atas","en":"Upper Chest"},{"id":"Bahu depan","en":"Anterior Deltoids"},{"id":"Triceps","en":"Triceps"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Bokong","en":"Glutes"},{"id":"Serratus","en":"Serratus Anterior"}]'::jsonb, '["Letakkan ujung kaki di atas kursi atau sofa yang kokoh, dan tangan di lantai selebar bahu.","Kencangkan seluruh otot inti dan bokong agar tubuh lurus membentuk sudut menurun.","Turunkan dada secara perlahan hingga hampir menyentuh lantai.","Dorong tubuh kembali ke atas dengan stabil."]'::jsonb, '["Place your feet elevated on a sturdy chair or sofa, with hands on the floor shoulder-width apart.","Tighten core and glutes to maintain a straight decline alignment.","Lower chest smoothly toward the floor.","Press forcefully back to starting plank position."]'::jsonb,
    '["Punggung bawah melengkung parah karena beban inti lebih berat.","Ketinggian kaki terlalu ekstrem sehingga beban bergeser murni ke leher/bahu tanpa kenyamanan."]'::jsonb, '["Arching the lower back excessively due to core weakness.","Elevating feet too high resulting in compromised shoulder mechanics."]'::jsonb, 'Tarik napas saat turun, buang napas saat dorong ke atas.', 'Inhale down, exhale as you press up.',
    'assets/images/exercises/decline_push_up_start.webp', 'assets/images/exercises/decline_push_up_end.webp', 'assets/images/exercises/decline_push_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'pike_push_up', 'Pike Push Up', 'Pike Push Up', 'push', 'main', 'advanced', 'reps',
    '[{"id":"Bahu","en":"Deltoids"},{"id":"Triceps","en":"Triceps"},{"id":"Dada atas","en":"Upper Chest"}]'::jsonb, '[{"id":"Trapezius","en":"Trapezius"},{"id":"Perut","en":"Core"},{"id":"Serratus","en":"Serratus"}]'::jsonb, '["Ambil posisi push up lalu majukan kaki ke arah tangan hingga pinggul terangkat tinggi membentuk huruf V terbalik.","Jaga punggung dan lengan tetap lurus.","Turunkan kepala ke arah depan tangan (membentuk tripod imajiner) secara terkontrol.","Dorong lantai kuat-kuat ke arah belakang atas hingga kembali ke posisi V terbalik."]'::jsonb, '["Start in a push up position and walk your feet forward so your hips rise into an inverted V-shape.","Keep your back and arms straight.","Lower your head forward between hands (creating an imaginary tripod).","Push back and up through your palms into the pike position."]'::jsonb,
    '["Menurunkan kepala tepat di antara kedua telapak tangan (seharusnya agak ke depan).","Punggung membungkuk parah (lutut boleh sedikit ditekuk jika hamstring kaku)."]'::jsonb, '["Lowering head directly between hands rather than creating a forward tripod angle.","Rounding the back excessively (bend knees slightly if hamstrings are tight)."]'::jsonb, 'Tarik napas saat turun ke depan, hembuskan napas saat mendorong ke atas.', 'Inhale descending forward, exhale pushing back and up.',
    'assets/images/exercises/pike_push_up_start.webp', 'assets/images/exercises/pike_push_up_end.webp', 'assets/images/exercises/pike_push_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'squat', 'Squat', 'Bodyweight Squat', 'legs', 'main', 'beginner', 'reps',
    '[{"id":"Quadriceps","en":"Quadriceps"},{"id":"Bokong","en":"Glutes"},{"id":"Hamstrings","en":"Hamstrings"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Punggung bawah","en":"Erector Spinae"},{"id":"Betis","en":"Calves"}]'::jsonb, '["Berdiri tegak dengan kaki dibuka selebar bahu, ujung jari kaki sedikit mengarah ke luar (15-30 derajat).","Busungkan dada, kunci perut, dan rentangkan tangan ke depan untuk keseimbangan.","Dorong pinggul ke belakang lalu tekuk lutut seolah hendak duduk di kursi.","Turun hingga paha minimal sejajar dengan lantai dengan tumit tetap menempel kuat.","Dorong melalui seluruh telapak kaki untuk kembali berdiri tegak sambil memeras otot bokong di atas."]'::jsonb, '["Stand tall with feet shoulder-width apart, toes pointing slightly outward (15-30 degrees).","Keep chest upright, engage core, and extend arms forward for balance.","Hinge at the hips and bend knees as if sitting down onto a chair.","Descend until thighs are at least parallel to the floor with heels firmly planted.","Drive through the floor to return to standing, squeezing glutes at the top."]'::jsonb,
    '["Lutut tertekuk ke dalam (valgus collapse) saat turun atau naik.","Tumit terangkat dari lantai dan bertumpu pada ujung jari kaki.","Dada terlalu membungkuk condong ke depan."]'::jsonb, '["Knees caving inward during movement.","Heels lifting off the ground, placing pressure on toes.","Rounding forward with excessive chest forward lean."]'::jsonb, 'Tarik napas dalam saat turun, hembuskan napas saat mendorong naik.', 'Inhale deeply on the way down, exhale as you drive up.',
    'assets/images/exercises/squat_start.webp', 'assets/images/exercises/squat_end.webp', 'assets/images/exercises/squat.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'lunges', 'Lunges', 'Lunges', 'legs', 'main', 'intermediate', 'reps',
    '[{"id":"Quadriceps","en":"Quadriceps"},{"id":"Bokong","en":"Glutes"},{"id":"Hamstrings","en":"Hamstrings"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Pinggul","en":"Hip Abductors"},{"id":"Betis","en":"Calves"}]'::jsonb, '["Berdiri tegak dengan kedua kaki rapat dan tangan di pinggang.","Langkahkan satu kaki ke depan secara mantap.","Turunkan pinggul hingga kedua lutut membentuk sudut sekitar 90 derajat.","Lutut belakang mendekati lantai tetapi tidak menyentuh lantai.","Dorong melalui tumit kaki depan untuk kembali ke posisi berdiri awal, lalu ganti kaki."]'::jsonb, '["Stand tall with feet hip-width apart and hands on hips.","Step forward with one leg into a deep stance.","Lower hips until both front and rear knees form approximately 90-degree angles.","Keep the back knee hovering just above the floor.","Drive through the front heel to return to the starting position, then alternate."]'::jsonb,
    '["Langkah terlalu pendek sehingga lutut depan terdorong jauh melewati ujung jari kaki secara tidak nyaman.","Badan condong miring ke samping karena kehilangan keseimbangan."]'::jsonb, '["Stepping too short, causing severe knee strain over the toes.","Leaning torso sideways due to loss of balance."]'::jsonb, 'Tarik napas saat melangkah dan merendahkan badan, buang napas saat mendorong kembali berdiri.', 'Inhale as you step and lower, exhale as you push back up.',
    'assets/images/exercises/lunges_start.webp', 'assets/images/exercises/lunges_end.webp', 'assets/images/exercises/lunges.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'glute_bridge', 'Glute Bridge', 'Glute Bridge', 'legs', 'main', 'beginner', 'reps',
    '[{"id":"Bokong","en":"Gluteus Maximus"},{"id":"Hamstrings","en":"Hamstrings"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Punggung bawah","en":"Lower Back"}]'::jsonb, '["Berbaring telentang di lantai dengan lutut ditekuk dan telapak kaki menapak rata selebar pinggul.","Letakkan kedua tangan di samping tubuh dengan telapak menghadap ke bawah.","Tekan tumit ke lantai dan angkat pinggul ke atas hingga membentuk garis lurus dari bahu ke lutut.","Kencangkan dan tahan kontraksi otot bokong di posisi puncak selama 1-2 detik.","Turunkan pinggul secara perlahan kembali ke lantai."]'::jsonb, '["Lie on your back with knees bent and feet flat on the floor, hip-width apart.","Rest your arms flat by your sides, palms facing down.","Drive through your heels to raise your hips until knees, hips, and shoulders form a straight line.","Squeeze and hold glutes firmly at the top for 1-2 seconds.","Lower hips under control back to the starting position."]'::jsonb,
    '["Mengangkat pinggul terlalu tinggi dengan melengkungkan punggung bawah (bukan kontraksi bokong).","Menumpu pada ujung jari kaki alih-alih tumit."]'::jsonb, '["Hyperextending the lower back at the top instead of hinging from glutes.","Pushing from toes rather than planting heels firmly."]'::jsonb, 'Buang napas saat mengangkat pinggul ke atas, tarik napas saat menurunkan pinggul.', 'Exhale as you bridge up, inhale as you lower down.',
    'assets/images/exercises/glute_bridge_start.webp', 'assets/images/exercises/glute_bridge_end.webp', 'assets/images/exercises/glute_bridge.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'calf_raise', 'Calf Raise', 'Calf Raise', 'legs', 'main', 'beginner', 'reps',
    '[{"id":"Betis atas","en":"Gastrocnemius"},{"id":"Betis bawah","en":"Soleus"}]'::jsonb, '[{"id":"Pergelangan kaki","en":"Ankle Stabilizers"},{"id":"Tulang kering","en":"Tibialis Anterior"}]'::jsonb, '["Berdiri tegak dengan kaki dibuka selebar pinggul di lantai rata (atau tepi undakan untuk rentang lebih dalam).","Jari tangan boleh menyentuh dinding untuk menjaga keseimbangan ringan.","Angkat tumit setinggi mungkin dengan bertumpu kuat pada bantalan jari kaki.","Tahan kontraksi puncak betis selama 1 detik.","Turunkan tumit kembali secara perlahan hingga menyentuh lantai."]'::jsonb, '["Stand tall with feet hip-width apart on a flat surface or edge of a step.","Lightly touch a wall for balance support if needed.","Raise your heels as high as possible, pressing through the balls of your feet.","Pause and squeeze calves firmly at the top for 1 second.","Lower your heels down slowly to the start position."]'::jsonb,
    '["Melompat-lompat dengan memanfaatkan pantulan tendo tanpa mengontrol tempo.","Pergelangan kaki tertekuk miring ke luar saat jinjit."]'::jsonb, '["Bouncing rapidly using tendon elasticity instead of muscular contraction.","Rolling ankles outward during full elevation."]'::jsonb, 'Hembuskan napas saat jinjit ke atas, tarik napas saat menurunkan tumit.', 'Exhale raising onto toes, inhale lowering heels.',
    'assets/images/exercises/calf_raise_start.webp', 'assets/images/exercises/calf_raise_end.webp', 'assets/images/exercises/calf_raise.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'split_squat', 'Split Squat', 'Split Squat', 'legs', 'main', 'intermediate', 'reps',
    '[{"id":"Quadriceps","en":"Quadriceps"},{"id":"Bokong","en":"Glutes"},{"id":"Hamstrings","en":"Hamstrings"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Pinggul","en":"Hip Stabilizers"}]'::jsonb, '["Ambil posisi kaki terbelah (satu kaki di depan dan satu di belakang) tanpa melangkah bolak-balik.","Jaga tubuh tegak dan berat badan terpusat pada telapak kaki depan.","Turunkan pinggul tegak lurus ke bawah hingga lutut belakang hampir menyentuh lantai.","Dorong kembali ke atas melalui tumit depan tanpa menggerakkan posisi telapak kaki.","Selesaikan seluruh rep pada satu sisi sebelum berganti kaki."]'::jsonb, '["Take a staggered stance with one foot forward and one foot back.","Keep torso upright and center balance on the front foot.","Lower hips straight down until back knee is just above the floor.","Drive through the front heel to return to top position without moving feet.","Complete all reps on one side before switching legs."]'::jsonb,
    '["Kedua kaki berada dalam satu garis lurus seperti tali akrobat (kaki harus selebar pinggul untuk stabil).","Condong terlalu jauh ke depan sehingga lutut depan menahan tekanan berlebih."]'::jsonb, '["Stancing on a tightrope instead of keeping feet hip-width apart.","Leaning excessively forward, overloading the front knee joint."]'::jsonb, 'Tarik napas saat turun, hembuskan napas saat mendorong ke atas.', 'Inhale descending, exhale driving back up.',
    'assets/images/exercises/split_squat_start.webp', 'assets/images/exercises/split_squat_end.webp', 'assets/images/exercises/split_squat.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'plank', 'Plank', 'Forearm Plank', 'core', 'main', 'beginner', 'duration_sec',
    '[{"id":"Perut","en":"Rectus Abdominis"},{"id":"Perut dalam","en":"Transverse Abdominis"},{"id":"Perut samping","en":"Obliques"}]'::jsonb, '[{"id":"Bahu","en":"Deltoids"},{"id":"Bokong","en":"Glutes"},{"id":"Paha depan","en":"Quadriceps"}]'::jsonb, '["Tengkurap lalu topang badan dengan kedua lengan bawah, siku tepat di bawah bahu.","Rapatkan kedua kaki dan bertumpu pada ujung jari kaki.","Luruskan tubuh dari kepala, punggung, bokong, hingga tumit.","Kunci otot perut dan kencangkan bokong dengan kuat seolah menahan pukulan ke perut.","Tahan posisi diam ini tanpa membiarkan pinggang melorot selama durasi target."]'::jsonb, '["Lie face down, resting on your forearms with elbows directly under shoulders.","Extend legs straight back, resting on the balls of your feet.","Form a rigid straight line from head to heels.","Engage your abs and squeeze glutes firmly as if preparing for a punch to the stomach.","Hold this static position firmly without letting hips sag for the target duration."]'::jsonb,
    '["Pinggul melorot ke bawah yang menyebabkan nyeri pada punggung bawah.","Bokong terangkat terlalu tinggi menyerupai segitiga.","Menahan napas (napas harus tetap teratur)."]'::jsonb, '["Hips sagging downward causing lower back hyperextension.","Poking hips too high in the air.","Holding your breath rather than breathing steadily."]'::jsonb, 'Bernapaslah secara teratur, tenang, dan stabil melalui hidung dan mulut saat menahan posisi.', 'Breathe steadily and calmly throughout the static hold.',
    'assets/images/exercises/plank_start.webp', 'assets/images/exercises/plank_end.webp', 'assets/images/exercises/plank.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'sit_up', 'Sit Up', 'Sit Up', 'core', 'main', 'intermediate', 'reps',
    '{"id":"Perut","en":"Rectus Abdominis"}'::jsonb, '[{"id":"Fleksor pinggul","en":"Hip Flexors"},{"id":"Perut samping","en":"Obliques"}]'::jsonb, '["Berbaring telentang dengan lutut ditekuk dan telapak kaki menapak rata di lantai.","Silangkan tangan di depan dada atau letakkan ujung jari di samping pelipis (jangan menarik leher).","Kencangkan otot perut dan angkat punggung dari lantai hingga posisi duduk tegak.","Turunkan punggung kembali ke lantai secara bertahap dan terkontrol."]'::jsonb, '["Lie on your back with knees bent and feet flat on the floor.","Cross arms across chest or place fingertips near temples without pulling your neck.","Contract your abdominal muscles to curl torso up to an upright sitting posture.","Lower back down slowly with controlled resistance."]'::jsonb,
    '["Menarik leher atau kepala dengan tangan ke depan yang mencederai leher.","Mengayunkan lengan untuk meminjam momentum alih-alih kekuatan perut."]'::jsonb, '["Pulling the neck or head forward with hands, straining the cervical spine.","Swinging arms violently for momentum instead of engaging abs."]'::jsonb, 'Hembuskan napas saat mengangkat tubuh ke atas, tarik napas saat kembali turun.', 'Exhale curling up, inhale lowering down.',
    'assets/images/exercises/sit_up_start.webp', 'assets/images/exercises/sit_up_end.webp', 'assets/images/exercises/sit_up.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'leg_raise', 'Leg Raise', 'Lying Leg Raise', 'core', 'main', 'intermediate', 'reps',
    '[{"id":"Perut bawah","en":"Lower Abs"},{"id":"Fleksor pinggul","en":"Hip Flexors"}]'::jsonb, '[{"id":"Perut samping","en":"Obliques"},{"id":"Punggung bawah","en":"Lower Back"}]'::jsonb, '["Berbaring telentang di matras dengan kedua kaki lurus dan rapat.","Letakkan kedua tangan di samping pinggul atau sedikit di bawah bokong untuk menyokong panggul.","Tekan punggung bawah rapat ke lantai agar tidak ada celah melengkung.","Angkat kedua kaki lurus ke atas hingga membentuk sudut 90 derajat terhadap lantai.","Turunkan kaki kembali secara perlahan hingga beberapa sentimeter di atas lantai tanpa membiarkan punggung bawah terangkat."]'::jsonb, '["Lie flat on your back with legs straight and joined together.","Place hands by your sides or slightly beneath glutes to support pelvis.","Flatten lower back firmly into the floor so there is no gap.","Raise legs straight up until they reach a 90-degree angle with the floor.","Lower legs slowly back down stopping a few inches above floor without letting lower back arch."]'::jsonb,
    '["Punggung bawah melengkung terangkat dari lantai saat kaki turun (risiko nyeri pinggang).","Menjatuhkan kaki terlalu cepat tanpa menahan beban."]'::jsonb, '["Arching lower back off the floor as legs descend.","Dropping legs abruptly without resisting on the way down."]'::jsonb, 'Hembuskan napas saat mengangkat kaki ke atas, tarik napas saat menurunkan kaki.', 'Exhale as you raise legs, inhale as you lower them down.',
    'assets/images/exercises/leg_raise_start.webp', 'assets/images/exercises/leg_raise_end.webp', 'assets/images/exercises/leg_raise.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'mountain_climber', 'Mountain Climber', 'Mountain Climber', 'core', 'main', 'intermediate', 'reps',
    '[{"id":"Perut","en":"Core / Abs"},{"id":"Fleksor pinggul","en":"Hip Flexors"},{"id":"Bahu","en":"Shoulders"}]'::jsonb, '[{"id":"Dada","en":"Chest"},{"id":"Triceps","en":"Triceps"},{"id":"Paha depan","en":"Quadriceps"}]'::jsonb, '["Mulai dari posisi push up / plank tinggi dengan tangan tepat di bawah bahu.","Tarik satu lutut ke arah dada secepat dan sedalam mungkin sambil menjaga pinggul tetap rendah.","Kembalikan kaki ke belakang bersamaan dengan menarik lutut sisi lainnya ke arah dada.","Lanjutkan gerakan berlari di tempat ini secara bergantian dengan ritme stabil dan inti tubuh terkunci."]'::jsonb, '["Start in a high plank position with hands stacked directly below shoulders.","Drive one knee toward your chest as far as possible while keeping hips low.","Quickly return that foot back while driving opposite knee forward.","Continue alternating in a fluid running motion with core firmly bracing."]'::jsonb,
    '["Bokong melompat-lompat tinggi ke udara.","Tangan bergeser menjauh ke depan dari garis bahu."]'::jsonb, '["Bouncing hips excessively high in the air.","Hands drifting forward ahead of shoulder alignment."]'::jsonb, 'Bernapas dengan ritme teratur dan stabil mengikuti langkah kaki.', 'Maintain rhythmic and steady breathing synced with foot strikes.',
    'assets/images/exercises/mountain_climber_start.webp', 'assets/images/exercises/mountain_climber_end.webp', 'assets/images/exercises/mountain_climber.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'burpee', 'Burpee', 'Burpee', 'full_body', 'main', 'advanced', 'reps',
    '[{"id":"Dada","en":"Chest"},{"id":"Paha depan","en":"Quadriceps"},{"id":"Perut","en":"Core"},{"id":"Bahu","en":"Shoulders"}]'::jsonb, '[{"id":"Bokong","en":"Glutes"},{"id":"Hamstrings","en":"Hamstrings"},{"id":"Betis","en":"Calves"},{"id":"Triceps","en":"Triceps"}]'::jsonb, '["Berdiri tegak dengan kaki dibuka selebar bahu.","Jongkok dan letakkan kedua telapak tangan di lantai di depan kaki.","Lemparkan kedua kaki ke belakang sekaligus ke posisi plank push up.","Lakukan satu kali push up hingga dada menyentuh lantai (atau tahan posisi plank untuk versi cepat).","Lompatkan kedua kaki kembali ke dekat tangan, lalu melompatlah tegak ke udara sambil menepuk tangan di atas kepala."]'::jsonb, '["Stand tall with feet shoulder-width apart.","Drop into a squat and place palms flat on the floor in front of feet.","Kick both feet back into a full push up plank.","Perform a full push up lowering chest to floor (or hold plank for speed burpee).","Jump feet back toward hands, then leap explosively into the air clapping hands overhead."]'::jsonb,
    '["Pinggang jatuh melorot ke lantai saat melempar kaki ke belakang.","Mendarat dengan lutut lurus kaku saat mendarat dari lompatan (harus mendarat lembut dengan lutut sedikit tertekuk)."]'::jsonb, '["Sagging lower back as feet kick back into plank.","Landing stiff-legged from the vertical jump (land softly with slight knee bend)."]'::jsonb, 'Tarik napas saat turun ke lantai, buang napas kuat saat mendorong dan melompat ke atas.', 'Inhale descending to floor, exhale forcefully jumping into the air.',
    'assets/images/exercises/burpee_start.webp', 'assets/images/exercises/burpee_end.webp', 'assets/images/exercises/burpee.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    primary_muscles, stabilizer_muscles, steps_id, steps_en,
    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'squat_jump', 'Squat Jump', 'Jump Squat', 'full_body', 'main', 'intermediate', 'reps',
    '[{"id":"Paha depan","en":"Quadriceps"},{"id":"Bokong","en":"Glutes"},{"id":"Betis","en":"Calves"}]'::jsonb, '[{"id":"Perut","en":"Core"},{"id":"Hamstrings","en":"Hamstrings"}]'::jsonb, '["Berdiri tegak dengan kaki dibuka selebar bahu.","Turun ke posisi squat penuh dengan mendorong pinggul ke belakang.","Secara eksplosif lompat setinggi mungkin ke udara menggunakan dorongan telapak kaki.","Mendaratlah dengan lembut menyerap benturan dari bantalan kaki menuju tumit dan langsung kembali meluncur ke posisi squat berikutnya."]'::jsonb, '["Stand with feet shoulder-width apart.","Lower into a full squat by hinging hips back.","Explosively leap as high as possible through your foot drive.","Land softly absorbing impact from balls of feet to heels, transitioning immediately into the next squat."]'::jsonb,
    '["Mendarat dengan keras di tumit tanpa meredam benturan pada lutut.","Lutut kolaps terlipat ke dalam saat mendarat."]'::jsonb, '["Heavy heel-first landing without knee deceleration.","Knees caving inward on impact absorption."]'::jsonb, 'Tarik napas saat turun ke squat, hembuskan napas kuat saat melompat ke udara.', 'Inhale down into squat, exhale forcefully on explosive leap.',
    'assets/images/exercises/squat_jump_start.webp', 'assets/images/exercises/squat_jump_end.webp', 'assets/images/exercises/squat_jump.webp', FALSE
) ON CONFLICT (id) DO UPDATE SET
    name_id = EXCLUDED.name_id,
    name_en = EXCLUDED.name_en,
    category = EXCLUDED.category,
    difficulty = EXCLUDED.difficulty,
    tracking_type = EXCLUDED.tracking_type,
    primary_muscles = EXCLUDED.primary_muscles,
    stabilizer_muscles = EXCLUDED.stabilizer_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en,
    common_mistakes_id = EXCLUDED.common_mistakes_id,
    common_mistakes_en = EXCLUDED.common_mistakes_en,
    breathing_tips_id = EXCLUDED.breathing_tips_id,
    breathing_tips_en = EXCLUDED.breathing_tips_en,
    start_pose_asset = EXCLUDED.start_pose_asset,
    end_pose_asset = EXCLUDED.end_pose_asset,
    animation_asset = EXCLUDED.animation_asset;

