defmodule Website.ImageAnalyzerTest do
  use ExUnit.Case, async: true
  
  alias Website.ImageAnalyzer

  describe "analyze_image/3" do
    test "analyzes image with basic metadata" do
      # Mock file path - analyzer will use fallback dimensions
      image_path = "/fake/path/test_image.jpg"
      
      result = ImageAnalyzer.analyze_image(image_path)
      
      assert result.width == 1200  # Fallback width
      assert result.height == 1200  # Fallback height  
      assert result.aspect_ratio == 1.0
      assert result.priority_score >= 1 and result.priority_score <= 10
      assert result.visual_weight in ["light", "medium", "heavy"]
      assert result.focal_point_x >= 0.0 and result.focal_point_x <= 1.0
      assert result.focal_point_y >= 0.0 and result.focal_point_y <= 1.0
    end

    test "calculates priority score based on filename keywords" do
      # Wedding photos should get higher priority
      wedding_result = ImageAnalyzer.analyze_image("/path/wedding_photo.jpg")
      general_result = ImageAnalyzer.analyze_image("/path/general_photo.jpg")
      
      assert wedding_result.priority_score > general_result.priority_score
    end

    test "determines visual weight based on content" do
      # Wedding photos should be heavy weight
      wedding_result = ImageAnalyzer.analyze_image("/path/wedding_day.jpg")
      assert wedding_result.visual_weight == "heavy"
      
      # Cooking photos should be light weight
      cooking_result = ImageAnalyzer.analyze_image("/path/curry_dish.jpg", "", "Cooking")
      assert cooking_result.visual_weight == "light"
      
      # Default should be medium
      normal_result = ImageAnalyzer.analyze_image("/path/normal_photo.jpg")
      assert normal_result.visual_weight == "medium"
    end

    test "estimates focal points based on filename hints" do
      # Group photos should focus center-right
      group_result = ImageAnalyzer.analyze_image("/path/with_friends.jpg")
      assert group_result.focal_point_x == 0.6
      assert group_result.focal_point_y == 0.35  # Face-focused
      
      # Portrait photos should center horizontally
      portrait_result = ImageAnalyzer.analyze_image("/path/me_cool.jpg")
      assert portrait_result.focal_point_x == 0.5
      assert portrait_result.focal_point_y == 0.35  # Face-focused
      
      # Food photos should center both ways
      food_result = ImageAnalyzer.analyze_image("/path/beef_curry.jpg")
      assert food_result.focal_point_x == 0.5
      assert food_result.focal_point_y == 0.5
    end

    test "uses description for priority scoring" do
      high_desc_result = ImageAnalyzer.analyze_image(
        "/path/photo.jpg", 
        "This is the best wedding photo ever"
      )
      
      low_desc_result = ImageAnalyzer.analyze_image(
        "/path/photo.jpg", 
        "Regular photo description"
      )
      
      assert high_desc_result.priority_score > low_desc_result.priority_score
    end

    test "priority score stays within valid range" do
      # Test with many high-priority keywords to ensure max is enforced
      result = ImageAnalyzer.analyze_image(
        "/path/wedding_surprised_with_friends.jpg",
        "Best wedding coolest photo"
      )
      
      assert result.priority_score >= 1
      assert result.priority_score <= 10
    end

    test "handles edge cases gracefully" do
      # Empty filename
      result = ImageAnalyzer.analyze_image("")
      assert is_map(result)
      assert result.priority_score >= 1
      
      # Filename with no extension
      result2 = ImageAnalyzer.analyze_image("/path/photo")
      assert is_map(result2)
    end
  end

  describe "batch_analyze_photos/1" do
    test "analyzes multiple photos and includes image_path" do
      photos = [
        %{image_path: "/path/photo1.jpg", description: "First photo", category: "Portraits"},
        %{image_path: "/path/photo2.jpg", description: "Second photo", category: "Landscapes"}
      ]
      
      results = ImageAnalyzer.batch_analyze_photos(photos)
      
      assert length(results) == 2
      
      [first, second] = results
      assert first.image_path == "/path/photo1.jpg"
      assert second.image_path == "/path/photo2.jpg"
      
      # Each result should have all metadata fields
      Enum.each(results, fn result ->
        assert Map.has_key?(result, :width)
        assert Map.has_key?(result, :height)
        assert Map.has_key?(result, :aspect_ratio)
        assert Map.has_key?(result, :priority_score)
        assert Map.has_key?(result, :visual_weight)
        assert Map.has_key?(result, :focal_point_x)
        assert Map.has_key?(result, :focal_point_y)
        assert Map.has_key?(result, :image_path)
      end)
    end

    test "handles empty photo list" do
      results = ImageAnalyzer.batch_analyze_photos([])
      assert results == []
    end

    test "uses photo-specific metadata for analysis" do
      photos = [
        %{image_path: "/path/wedding.jpg", description: "Wedding day", category: "Events"},
        %{image_path: "/path/food.jpg", description: "Delicious meal", category: "Cooking"}
      ]
      
      results = ImageAnalyzer.batch_analyze_photos(photos)
      [wedding, food] = results
      
      # Wedding should have higher priority and heavy weight
      assert wedding.priority_score > food.priority_score
      assert wedding.visual_weight == "heavy"
      assert food.visual_weight == "light"
    end
  end

  # Test private function behavior indirectly through public interface
  describe "priority scoring behavior" do
    test "wedding keywords increase score" do
      wedding_result = ImageAnalyzer.analyze_image("/path/wedding_photo.jpg")
      normal_result = ImageAnalyzer.analyze_image("/path/normal_photo.jpg")
      
      assert wedding_result.priority_score > normal_result.priority_score
    end

    test "group photo keywords increase score" do
      group_result = ImageAnalyzer.analyze_image("/path/with_sarah.jpg")
      normal_result = ImageAnalyzer.analyze_image("/path/solo_photo.jpg")
      
      assert group_result.priority_score > normal_result.priority_score
    end

    test "general keywords decrease score" do
      general_result = ImageAnalyzer.analyze_image("/path/general_photo.jpg")
      normal_result = ImageAnalyzer.analyze_image("/path/normal_photo.jpg")
      
      assert general_result.priority_score < normal_result.priority_score
    end
  end
end