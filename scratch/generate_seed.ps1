$json = Get-Content 'assets/data/exercises.json' -Raw | ConvertFrom-Json

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("-- ==============================================================================")
[void]$sb.AppendLine("-- Seed: 17 Exercises from assets/data/exercises.json")
[void]$sb.AppendLine("-- Database: Supabase (PostgreSQL)")
[void]$sb.AppendLine("-- ==============================================================================")
[void]$sb.AppendLine()

foreach ($ex in $json) {
    $id = $ex.id.Replace("'", "''")
    $name_id = $ex.name.id.Replace("'", "''")
    $name_en = $ex.name.en.Replace("'", "''")
    $category = $ex.category.Replace("'", "''")
    $difficulty = $ex.difficulty.Replace("'", "''")
    $tracking_type = $ex.tracking_type.Replace("'", "''")
    
    $primary_muscles = ($ex.primary_muscles | ConvertTo-Json -Compress).Replace("'", "''")
    $stabilizer_muscles = ($ex.stabilizer_muscles | ConvertTo-Json -Compress).Replace("'", "''")
    
    $steps_id = ($ex.steps.id | ConvertTo-Json -Compress).Replace("'", "''")
    $steps_en = ($ex.steps.en | ConvertTo-Json -Compress).Replace("'", "''")
    
    $common_mistakes_id = ($ex.common_mistakes.id | ConvertTo-Json -Compress).Replace("'", "''")
    $common_mistakes_en = ($ex.common_mistakes.en | ConvertTo-Json -Compress).Replace("'", "''")
    
    $breathing_id = if ($ex.breathing.id) { $ex.breathing.id.Replace("'", "''") } else { "" }
    $breathing_en = if ($ex.breathing.en) { $ex.breathing.en.Replace("'", "''") } else { "" }
    
    $start_pose = if ($ex.media.start_pose) { $ex.media.start_pose.Replace("'", "''") } else { "" }
    $end_pose = if ($ex.media.end_pose) { $ex.media.end_pose.Replace("'", "''") } else { "" }
    $animation = "assets/images/exercises/$id.webp"

    [void]$sb.AppendLine("INSERT INTO public.exercises (")
    [void]$sb.AppendLine("    id, name_id, name_en, category, stage, difficulty, tracking_type,")
    [void]$sb.AppendLine("    primary_muscles, stabilizer_muscles, steps_id, steps_en,")
    [void]$sb.AppendLine("    common_mistakes_id, common_mistakes_en, breathing_tips_id, breathing_tips_en,")
    [void]$sb.AppendLine("    start_pose_asset, end_pose_asset, animation_asset, is_custom")
    [void]$sb.AppendLine(") VALUES (")
    [void]$sb.AppendLine("    '$id', '$name_id', '$name_en', '$category', 'main', '$difficulty', '$tracking_type',")
    [void]$sb.AppendLine("    '$primary_muscles'::jsonb, '$stabilizer_muscles'::jsonb, '$steps_id'::jsonb, '$steps_en'::jsonb,")
    [void]$sb.AppendLine("    '$common_mistakes_id'::jsonb, '$common_mistakes_en'::jsonb, '$breathing_id', '$breathing_en',")
    [void]$sb.AppendLine("    '$start_pose', '$end_pose', '$animation', FALSE")
    [void]$sb.AppendLine(") ON CONFLICT (id) DO UPDATE SET")
    [void]$sb.AppendLine("    name_id = EXCLUDED.name_id,")
    [void]$sb.AppendLine("    name_en = EXCLUDED.name_en,")
    [void]$sb.AppendLine("    category = EXCLUDED.category,")
    [void]$sb.AppendLine("    difficulty = EXCLUDED.difficulty,")
    [void]$sb.AppendLine("    tracking_type = EXCLUDED.tracking_type,")
    [void]$sb.AppendLine("    primary_muscles = EXCLUDED.primary_muscles,")
    [void]$sb.AppendLine("    stabilizer_muscles = EXCLUDED.stabilizer_muscles,")
    [void]$sb.AppendLine("    steps_id = EXCLUDED.steps_id,")
    [void]$sb.AppendLine("    steps_en = EXCLUDED.steps_en,")
    [void]$sb.AppendLine("    common_mistakes_id = EXCLUDED.common_mistakes_id,")
    [void]$sb.AppendLine("    common_mistakes_en = EXCLUDED.common_mistakes_en,")
    [void]$sb.AppendLine("    breathing_tips_id = EXCLUDED.breathing_tips_id,")
    [void]$sb.AppendLine("    breathing_tips_en = EXCLUDED.breathing_tips_en,")
    [void]$sb.AppendLine("    start_pose_asset = EXCLUDED.start_pose_asset,")
    [void]$sb.AppendLine("    end_pose_asset = EXCLUDED.end_pose_asset,")
    [void]$sb.AppendLine("    animation_asset = EXCLUDED.animation_asset;")
    [void]$sb.AppendLine()
}

[System.IO.File]::WriteAllText('supabase/seed_exercises.sql', $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Output "Successfully generated supabase/seed_exercises.sql"

