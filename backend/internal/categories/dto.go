package categories

type CreateCategoryRequest struct {
	Name      string  `json:"name" validate:"required"`
	Slug      string  `json:"slug" validate:"required"`
	ParentID  *string `json:"parent_id"`
	Icon      *string `json:"icon"`
	SortOrder int     `json:"sort_order"`
}

type UpdateCategoryRequest struct {
	Name      string  `json:"name" validate:"required"`
	Slug      string  `json:"slug" validate:"required"`
	ParentID  *string `json:"parent_id"`
	Icon      *string `json:"icon"`
	SortOrder int     `json:"sort_order"`
}
