defmodule Website.ImageAnalyzer do
  @moduledoc """
  Analyzes images to extract metadata like dimensions, aspect ratios, and estimates 
  priority scores and focal points based on file names and content hints.
  """

  @doc """
  Analyzes an image file and returns metadata map.
  For now, uses filename-based heuristics since we don't have image processing libs.
  """
  def analyze_image(image_path, description \\ "", category \\ "") do
    # Extract filename for analysis
    filename = Path.basename(image_path, Path.extname(image_path))
    
    # Estimate dimensions based on common patterns or defaults
    {width, height} = estimate_dimensions(filename, image_path)
    
    %{
      width: width,
      height: height,
      aspect_ratio: width / height,
      priority_score: estimate_priority_score(filename, description, category),
      visual_weight: estimate_visual_weight(filename, description, category),
      focal_point_x: estimate_focal_point_x(filename, description),
      focal_point_y: estimate_focal_point_y(filename, description)
    }
  end

  # Estimates image dimensions - in a real app, we'd use an image processing library
  defp estimate_dimensions(filename, _image_path) do
    cond do
      # Wedding/group photos tend to be landscape
      String.contains?(filename, ["wedding", "group", "friends"]) -> {1600, 1200}
      
      # Portrait photos tend to be vertical
      String.contains?(filename, ["portrait", "with_", "me_"]) -> {1200, 1600}
      
      # Food photos are often square or slightly landscape
      String.contains?(filename, ["beef", "chicken", "curry", "soup", "pasta"]) -> {1200, 1200}
      
      # Travel/landscape photos are wide
      String.contains?(filename, ["abu_dhabi", "travel", "landscape"]) -> {1920, 1080}
      
      # Default dimensions
      true -> {1200, 1200}
    end
  end

  # Estimates priority score based on content hints
  defp estimate_priority_score(filename, description, _category) do
    base_score = 5
    
    score = base_score
    |> add_if_contains(filename, ["wedding", "surprised"], 3)
    |> add_if_contains(filename, ["with_"], 2)
    |> add_if_contains(description, ["wedding", "best", "coolest"], 2)
    |> add_if_contains(filename, ["me_cool"], 2)
    |> subtract_if_contains(filename, ["general", "curry"], 1)
    
    # Ensure score is within valid range
    max(1, min(10, score))
  end

  # Estimates visual weight based on content
  defp estimate_visual_weight(filename, description, category) do
    cond do
      # Heavy weight for important moments
      String.contains?(filename, ["wedding", "surprised"]) or 
      String.contains?(description, ["wedding", "coolest"]) -> "heavy"
      
      # Light weight for food/simple shots
      category == "Cooking" or 
      String.contains?(filename, ["curry", "soup", "pasta"]) -> "light"
      
      # Default to medium
      true -> "medium"
    end
  end

  # Estimates horizontal focal point
  defp estimate_focal_point_x(filename, _description) do
    cond do
      # Group photos often have subjects in center-right
      String.contains?(filename, ["with_", "friends", "group"]) -> 0.6
      
      # Portrait shots usually center
      String.contains?(filename, ["me_"]) -> 0.5
      
      # Food photos center the dish
      String.contains?(filename, ["beef", "chicken", "curry"]) -> 0.5
      
      # Default center
      true -> 0.5
    end
  end

  # Estimates vertical focal point
  defp estimate_focal_point_y(filename, _description) do
    cond do
      # Face-focused photos have higher focal point
      String.contains?(filename, ["me_", "with_"]) -> 0.35
      
      # Food photos center vertically
      String.contains?(filename, ["beef", "chicken", "curry", "soup"]) -> 0.5
      
      # Landscape photos focus on horizon
      String.contains?(filename, ["abu_dhabi"]) -> 0.6
      
      # Default center
      true -> 0.5
    end
  end

  # Helper to add score if any terms are found
  defp add_if_contains(score, text, terms, amount) do
    if Enum.any?(terms, &String.contains?(String.downcase(text), &1)) do
      score + amount
    else
      score
    end
  end

  # Helper to subtract score if any terms are found
  defp subtract_if_contains(score, text, terms, amount) do
    if Enum.any?(terms, &String.contains?(String.downcase(text), &1)) do
      score - amount
    else
      score
    end
  end

  @doc """
  Batch analyzes all photos and returns a list of metadata maps with image_path keys.
  """
  def batch_analyze_photos(photos) when is_list(photos) do
    Enum.map(photos, fn photo ->
      metadata = analyze_image(photo.image_path, photo.description, photo.category)
      Map.put(metadata, :image_path, photo.image_path)
    end)
  end
end