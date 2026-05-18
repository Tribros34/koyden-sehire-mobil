package categories

import "time"

type Category struct {
	ID        string    `db:"id" json:"id"`
	Name      string    `db:"name" json:"name"`
	Slug      string    `db:"slug" json:"slug"`
	ParentID  *string   `db:"parent_id" json:"parent_id"`
	Icon      *string   `db:"icon" json:"icon"`
	SortOrder int       `db:"sort_order" json:"sort_order"`
	IsActive  bool      `db:"is_active" json:"is_active"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
	UpdatedAt time.Time `db:"updated_at" json:"updated_at"`
}

type CategoryWithChildren struct {
	Category
	Children []Category `json:"children,omitempty"`
}
