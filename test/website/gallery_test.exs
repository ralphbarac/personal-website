defmodule Website.GalleryTest do
  use Website.DataCase

  alias Website.Gallery
  alias Website.{Photo, PhotoCategory}

  describe "photos" do
    test "list_photos/0 returns all photos ordered by priority and date" do
      category = photo_category_fixture()
      
      # Create photos with different priority scores
      photo1 = photo_fixture(%{priority_score: 8, photo_category_id: category.id})
      :timer.sleep(10)  # Ensure different timestamps
      photo2 = photo_fixture(%{priority_score: 10, photo_category_id: category.id})
      :timer.sleep(10)
      _photo3 = photo_fixture(%{priority_score: 8, photo_category_id: category.id})
      
      photos = Gallery.list_photos()
      
      # Should be ordered by priority (desc), then by insertion date (desc)
      assert length(photos) == 3
      assert hd(photos).id == photo2.id  # Highest priority
      # Last photo should be the oldest with lowest priority (photo1)
      assert List.last(photos).id == photo1.id
    end

    test "list_photos_by_category/1 filters by category name" do
      portraits = photo_category_fixture(%{name: "Portraits"})
      landscapes = photo_category_fixture(%{name: "Landscapes"})
      
      portrait_photo = photo_fixture(%{photo_category_id: portraits.id})
      _landscape_photo = photo_fixture(%{photo_category_id: landscapes.id})
      
      photos = Gallery.list_photos_by_category("Portraits")
      
      assert length(photos) == 1
      assert hd(photos).id == portrait_photo.id
      assert hd(photos).photo_category.name == "Portraits"
    end

    test "list_photos_by_category/1 returns all photos for 'All' category" do
      category = photo_category_fixture()
      photo1 = photo_fixture(%{photo_category_id: category.id})
      photo2 = photo_fixture(%{photo_category_id: category.id})
      
      photos_all = Gallery.list_photos_by_category("All")
      photos_nil = Gallery.list_photos_by_category(nil)
      
      assert length(photos_all) == 2
      assert length(photos_nil) == 2
      assert Enum.map(photos_all, & &1.id) == Enum.map(photos_nil, & &1.id)
    end

    test "list_photos_by_category_id/1 filters by category ID" do
      category1 = photo_category_fixture()
      category2 = photo_category_fixture(%{name: "Category 2"})
      
      photo1 = photo_fixture(%{photo_category_id: category1.id})
      _photo2 = photo_fixture(%{photo_category_id: category2.id})
      
      photos = Gallery.list_photos_by_category_id(category1.id)
      
      assert length(photos) == 1
      assert hd(photos).id == photo1.id
    end

    test "get_photo!/1 returns the photo with given id" do
      category = photo_category_fixture()
      photo = photo_fixture(%{photo_category_id: category.id})
      
      found_photo = Gallery.get_photo!(photo.id)
      
      assert found_photo.id == photo.id
      assert found_photo.photo_category.name == category.name
    end

    test "get_photo!/1 raises error when photo does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Gallery.get_photo!(-1)
      end
    end

    test "create_photo/1 with valid data creates a photo" do
      category = photo_category_fixture()
      
      valid_attrs = %{
        description: "Beautiful sunset",
        image_path: "/images/sunset.jpg",
        width: 1200,
        height: 800,
        priority_score: 8,
        photo_category_id: category.id
      }
      
      assert {:ok, %Photo{} = photo} = Gallery.create_photo(valid_attrs)
      assert photo.description == "Beautiful sunset"
      assert photo.image_path == "/images/sunset.jpg"
      assert photo.aspect_ratio == 1.5  # Calculated from width/height
      assert photo.priority_score == 8
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_photo(%{description: ""})
    end

    test "create_photo/1 requires image_path for new photos" do
      category = photo_category_fixture()
      
      attrs = %{
        description: "Photo without image path",
        photo_category_id: category.id
      }
      
      assert {:error, %Ecto.Changeset{} = changeset} = Gallery.create_photo(attrs)
      assert "can't be blank" in errors_on(changeset).image_path
    end

    test "update_photo/2 with valid data updates the photo" do
      category = photo_category_fixture()
      photo = photo_fixture(%{photo_category_id: category.id})
      
      update_attrs = %{description: "Updated description"}
      
      assert {:ok, %Photo{} = updated_photo} = Gallery.update_photo(photo, update_attrs)
      assert updated_photo.description == "Updated description"
    end

    test "update_photo/2 with invalid data returns error changeset" do
      category = photo_category_fixture()
      photo = photo_fixture(%{photo_category_id: category.id})
      
      assert {:error, %Ecto.Changeset{}} = Gallery.update_photo(photo, %{description: ""})
      # Photo should remain unchanged
      assert Gallery.get_photo!(photo.id).description == photo.description
    end

    test "delete_photo/1 deletes the photo" do
      category = photo_category_fixture()
      photo = photo_fixture(%{photo_category_id: category.id})
      
      assert {:ok, %Photo{}} = Gallery.delete_photo(photo)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_photo!(photo.id) end
    end

    test "change_photo/1 returns a photo changeset" do
      category = photo_category_fixture()
      photo = photo_fixture(%{photo_category_id: category.id})
      
      assert %Ecto.Changeset{} = Gallery.change_photo(photo)
    end

    test "count_photos/0 returns total photo count" do
      category = photo_category_fixture()
      _photo1 = photo_fixture(%{photo_category_id: category.id})
      _photo2 = photo_fixture(%{photo_category_id: category.id})
      
      assert Gallery.count_photos() == 2
    end

    test "count_photos_by_category/0 returns count by category" do
      portraits = photo_category_fixture(%{name: "Portraits"})
      landscapes = photo_category_fixture(%{name: "Landscapes"})
      
      _photo1 = photo_fixture(%{photo_category_id: portraits.id})
      _photo2 = photo_fixture(%{photo_category_id: portraits.id})
      _photo3 = photo_fixture(%{photo_category_id: landscapes.id})
      
      counts = Gallery.count_photos_by_category()
      
      assert length(counts) == 2
      
      landscape_count = Enum.find(counts, &(&1.category == "Landscapes"))
      portrait_count = Enum.find(counts, &(&1.category == "Portraits"))
      
      assert landscape_count.count == 1
      assert portrait_count.count == 2
    end
  end

  describe "photo_categories" do
    test "list_photo_categories/0 returns all categories ordered by name" do
      _category_b = photo_category_fixture(%{name: "B Category"})
      _category_a = photo_category_fixture(%{name: "A Category"})
      
      categories = Gallery.list_photo_categories()
      
      assert length(categories) == 2
      assert hd(categories).name == "A Category"
      assert List.last(categories).name == "B Category"
    end

    test "list_photo_categories_with_counts/0 includes photo counts" do
      category = photo_category_fixture()
      _photo1 = photo_fixture(%{photo_category_id: category.id})
      _photo2 = photo_fixture(%{photo_category_id: category.id})
      empty_category = photo_category_fixture(%{name: "Empty Category"})
      
      categories_with_counts = Gallery.list_photo_categories_with_counts()
      
      category_with_photos = Enum.find(categories_with_counts, &(&1.category.id == category.id))
      empty_cat_with_count = Enum.find(categories_with_counts, &(&1.category.id == empty_category.id))
      
      assert category_with_photos.photo_count == 2
      assert empty_cat_with_count.photo_count == 0
    end

    test "get_category_names_with_all/0 includes 'All' option" do
      _category1 = photo_category_fixture(%{name: "Portraits"})
      _category2 = photo_category_fixture(%{name: "Landscapes"})
      
      names = Gallery.get_category_names_with_all()
      
      assert "All" in names
      assert "Landscapes" in names
      assert "Portraits" in names
      assert hd(names) == "All"
    end

    test "get_category_names/0 returns only category names" do
      _category1 = photo_category_fixture(%{name: "Portraits"})
      _category2 = photo_category_fixture(%{name: "Landscapes"})
      
      names = Gallery.get_category_names()
      
      assert "All" not in names
      assert "Landscapes" in names
      assert "Portraits" in names
    end

    test "get_photo_category!/1 returns the category with given id" do
      category = photo_category_fixture()
      
      found_category = Gallery.get_photo_category!(category.id)
      
      assert found_category.id == category.id
      assert found_category.name == category.name
    end

    test "get_photo_category!/1 raises error when category does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Gallery.get_photo_category!(-1)
      end
    end

    test "get_photo_category_by_name/1 returns category by name" do
      category = photo_category_fixture(%{name: "Portraits"})
      
      found_category = Gallery.get_photo_category_by_name("Portraits")
      
      assert found_category.id == category.id
      assert found_category.name == "Portraits"
    end

    test "get_photo_category_by_name/1 returns nil for non-existent category" do
      assert Gallery.get_photo_category_by_name("Non-existent") == nil
    end

    test "get_photo_category_by_slug/1 returns category by slug" do
      category = photo_category_fixture(%{name: "Portraits", slug: "portraits"})
      
      found_category = Gallery.get_photo_category_by_slug("portraits")
      
      assert found_category.id == category.id
      assert found_category.slug == "portraits"
    end

    test "create_photo_category/1 with valid data creates a category" do
      valid_attrs = %{name: "New Category", slug: "new-category"}
      
      assert {:ok, %PhotoCategory{} = category} = Gallery.create_photo_category(valid_attrs)
      assert category.name == "New Category"
      assert category.slug == "new-category"
    end

    test "create_photo_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_photo_category(%{name: ""})
    end

    test "update_photo_category/2 with valid data updates the category" do
      category = photo_category_fixture()
      update_attrs = %{name: "Updated Category"}
      
      assert {:ok, %PhotoCategory{} = updated_category} = Gallery.update_photo_category(category, update_attrs)
      assert updated_category.name == "Updated Category"
    end

    test "update_photo_category/2 with invalid data returns error changeset" do
      category = photo_category_fixture()
      
      assert {:error, %Ecto.Changeset{}} = Gallery.update_photo_category(category, %{name: ""})
      assert Gallery.get_photo_category!(category.id).name == category.name
    end

    test "delete_photo_category/1 deletes category with no photos" do
      category = photo_category_fixture()
      
      assert {:ok, %PhotoCategory{}} = Gallery.delete_photo_category(category)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_photo_category!(category.id) end
    end

    test "delete_photo_category/1 returns error when category has photos" do
      category = photo_category_fixture()
      _photo = photo_fixture(%{photo_category_id: category.id})
      
      assert {:error, :has_photos} = Gallery.delete_photo_category(category)
      assert Gallery.get_photo_category!(category.id)  # Category still exists
    end

    test "change_photo_category/1 returns a category changeset" do
      category = photo_category_fixture()
      
      assert %Ecto.Changeset{} = Gallery.change_photo_category(category)
    end
  end

  # Test fixtures
  defp photo_category_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])
    
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "Test Category #{unique_id}",
        slug: "test-category-#{unique_id}",
        color: "#10b981"
      })
      |> Gallery.create_photo_category()

    category
  end

  defp photo_fixture(attrs \\ %{}) do
    {:ok, photo} =
      attrs
      |> Enum.into(%{
        description: "Test photo description",
        image_path: "/images/test.jpg",
        width: 1200,
        height: 800,
        priority_score: 5,
        visual_weight: :medium,
        focal_point_x: 0.5,
        focal_point_y: 0.5
      })
      |> Gallery.create_photo()

    photo
  end
end