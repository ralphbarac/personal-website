defmodule Website.ImageAnalyzer do
  @moduledoc """
  Analyzes images to extract metadata like dimensions, aspect ratios, and estimates 
  priority scores and focal points based on file names and content hints.
  """

  @doc """
  Analyzes an image file and returns metadata map.
  Uses ex_image_info to get real dimensions from image headers, and filename-based 
  heuristics for priority scoring and focal point estimation.
  """
  def analyze_image(image_path, description \\ "", category \\ "") do
    # Extract filename for analysis
    filename = Path.basename(image_path, Path.extname(image_path))

    # Get real dimensions from image file
    {width, height} = get_real_dimensions(image_path)

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

  # Gets real image dimensions from file headers using ex_image_info
  defp get_real_dimensions(image_path) do
    # Convert web path (/images/file.jpg) to filesystem path (priv/static/images/file.jpg)
    file_path = resolve_file_path(image_path)
    
    try do
      case File.read(file_path) do
        {:ok, file_data} ->
          case ExImageInfo.info(file_data) do
            {_format, width, height, _variant} -> 
              {width, height}
            # fallback if image info can't be parsed
            _ -> 
              require Logger
              Logger.warning("ExImageInfo could not parse image: #{file_path}")
              {1200, 1200}
          end

        # fallback if file can't be read
        {:error, reason} ->
          require Logger
          Logger.warning("Could not read image file: #{file_path}, reason: #{inspect(reason)}")
          {1200, 1200}
      end
    rescue
      error ->
        require Logger
        Logger.warning("ImageAnalyzer error for #{file_path}: #{inspect(error)}")
        {1200, 1200}
    end
  end

  # Converts web paths (/images/file.jpg) to filesystem paths (priv/static/images/file.jpg)
  defp resolve_file_path(image_path) do
    case Application.get_env(:website, :env) do
      :prod ->
        # In production, use Application.app_dir to get the correct path
        static_path = Path.join([Application.app_dir(:website), "priv", "static"])
        Path.join(static_path, String.trim_leading(image_path, "/"))
      _ ->
        # In development/test, use relative path from project root
        Path.join("priv/static", String.trim_leading(image_path, "/"))
    end
  end

  # Estimates priority score based on content hints
  defp estimate_priority_score(filename, description, _category) do
    base_score = 5

    score =
      base_score
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
          String.contains?(description, ["wedding", "coolest"]) ->
        "heavy"

      # Light weight for food/simple shots
      category == "Cooking" or
          String.contains?(filename, ["curry", "soup", "pasta"]) ->
        "light"

      # Default to medium
      true ->
        "medium"
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
