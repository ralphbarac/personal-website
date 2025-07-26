defmodule Website.PhotoLayoutEngine do
  @moduledoc """
  Smart layout engine for photo gallery that generates balanced collage layouts
  based on image metadata and visual importance.
  """

  @doc """
  Generates layout data for a list of photos with intelligent size assignment
  and balanced distribution.
  """
  def generate_layout(photos) when is_list(photos) do
    photos
    |> mix_categories()
    |> Enum.with_index()
    |> Enum.map(&assign_layout_data/1)
    |> balance_layout()
  end

  # Mixes photos from different categories for better visual distribution
  defp mix_categories(photos) do
    # Group photos by category name (via association)
    grouped =
      Enum.group_by(photos, fn photo ->
        if photo.photo_category, do: photo.photo_category.name, else: "Uncategorized"
      end)

    # If only one category or less than 3 photos, return as-is
    if map_size(grouped) <= 1 or length(photos) < 3 do
      photos
    else
      # Interleave photos from different categories
      interleave_categories(grouped)
    end
  end

  # Interleaves photos from different categories in a round-robin fashion
  defp interleave_categories(grouped_photos) do
    # Convert to list of {category, photos} and sort by category name for consistency
    category_lists =
      grouped_photos
      |> Enum.to_list()
      |> Enum.sort_by(fn {category, _photos} -> category end)
      |> Enum.map(fn {_category, photos} -> photos end)

    # Interleave using round-robin
    round_robin_interleave(category_lists)
  end

  # Round-robin interleaving algorithm
  defp round_robin_interleave(lists) do
    round_robin_interleave(lists, [])
  end

  defp round_robin_interleave([], acc) do
    # All lists are empty, return accumulated results in reverse order
    Enum.reverse(acc)
  end

  defp round_robin_interleave(lists, acc) do
    # Filter out empty lists first
    non_empty_lists = Enum.filter(lists, &(&1 != []))

    # If no non-empty lists remain, we're done
    if non_empty_lists == [] do
      Enum.reverse(acc)
    else
      # Take one item from each non-empty list
      {items, remaining_lists} =
        non_empty_lists
        |> Enum.reduce({[], []}, fn
          [head | tail], {items, remaining} ->
            {[head | items], [tail | remaining]}
        end)

      # Add items to accumulator (reverse to maintain round-robin order)
      new_acc = Enum.reverse(items) ++ acc

      # Continue with remaining lists
      round_robin_interleave(remaining_lists, new_acc)
    end
  end

  # Assigns initial size class and Tailwind classes based on photo metadata
  defp assign_layout_data({photo, index}) do
    size_class = determine_size_class(photo)

    %{
      photo: photo,
      index: index,
      size_class: size_class,
      container_classes: build_container_classes(size_class, photo),
      image_classes: build_image_classes(photo)
    }
  end

  # Determines size class based on aspect ratio: small (1x1), wide (2x1), or tall (1x2)
  defp determine_size_class(photo) do
    aspect_ratio = photo.aspect_ratio || calculate_aspect_ratio(photo)

    cond do
      # Wide images (landscape orientation)
      # 2x1 units
      aspect_ratio > 1.4 -> :wide
      # Tall images (portrait orientation)
      # 1x2 units
      aspect_ratio < 0.8 -> :tall
      # Square or nearly square images
      # 1x1 units
      true -> :small
    end
  end

  # Calculate aspect ratio from width/height if not stored
  defp calculate_aspect_ratio(photo) do
    if photo.width && photo.height && photo.height != 0 do
      photo.width / photo.height
    else
      # Default to square if no dimensions
      1.0
    end
  end

  # Builds Tailwind container classes based on size class
  defp build_container_classes(size_class, _photo) do
    base_classes = "group cursor-pointer"

    size_classes =
      case size_class do
        # 2x1 units - landscape
        :wide -> "col-span-2 row-span-1"
        # 1x2 units - portrait
        :tall -> "col-span-1 row-span-2"
        # 1x1 units - square
        :small -> "col-span-1 row-span-1"
      end

    "#{base_classes} #{size_classes}"
  end

  # Builds image classes including focal point positioning
  defp build_image_classes(photo) do
    base_classes = "object-cover w-full h-full"
    position_class = get_object_position_class(photo)

    "#{base_classes} #{position_class}"
  end

  # Maps focal point coordinates to Tailwind object position classes
  defp get_object_position_class(photo) do
    x = photo.focal_point_x || 0.5
    y = photo.focal_point_y || 0.5

    cond do
      # Center region (0.4-0.6)
      x >= 0.4 and x <= 0.6 and y >= 0.4 and y <= 0.6 -> "object-center"
      # Corner regions
      x < 0.4 and y < 0.4 -> "object-left-top"
      x > 0.6 and y < 0.4 -> "object-right-top"
      x < 0.4 and y > 0.6 -> "object-left-bottom"
      x > 0.6 and y > 0.6 -> "object-right-bottom"
      # Edge regions
      x < 0.4 -> "object-left"
      x > 0.6 -> "object-right"
      y < 0.4 -> "object-top"
      y > 0.6 -> "object-bottom"
      # Fallback to center
      true -> "object-center"
    end
  end

  # Balances layout to avoid clustering large images and maintain harmony
  defp balance_layout(layout_items) do
    layout_items
    |> distribute_large_images()
    |> ensure_visual_balance()
  end

  # Ensures max 1 large image per row and distributes them evenly
  defp distribute_large_images(layout_items) do
    # For now, keep the original order but could implement more sophisticated logic
    # This is where we could rearrange items to prevent clustering
    layout_items
  end

  # Ensures overall visual balance across the layout
  defp ensure_visual_balance(layout_items) do
    # Could implement logic to balance visual weight distribution
    # For now, return as-is
    layout_items
  end

  @doc """
  Gets the size class for a photo as an atom.
  Useful for conditional rendering in templates.
  """
  def get_size_class(photo) do
    determine_size_class(photo)
  end

  @doc """
  Gets responsive grid classes for the gallery container.
  """
  def get_grid_classes do
    """
    grid grid-cols-4 md:grid-cols-6 lg:grid-cols-8 
    gap-4 auto-rows-[200px]
    """
  end
end
