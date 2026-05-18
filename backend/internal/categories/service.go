package categories

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListPublic() ([]CategoryWithChildren, error) {
	cats, err := s.repo.ListActive()
	if err != nil {
		return nil, err
	}

	// Use a pointer slice so that pointers remain valid after appends
	// (taking &roots[i] on a value slice causes stale pointers on reallocation).
	parentMap := make(map[string]*CategoryWithChildren)
	var rootPtrs []*CategoryWithChildren

	for i := range cats {
		if cats[i].ParentID == nil {
			wc := &CategoryWithChildren{Category: cats[i], Children: []Category{}}
			rootPtrs = append(rootPtrs, wc)
			parentMap[cats[i].ID] = wc
		}
	}

	for i := range cats {
		if cats[i].ParentID != nil {
			if parent, ok := parentMap[*cats[i].ParentID]; ok {
				parent.Children = append(parent.Children, cats[i])
			}
		}
	}

	roots := make([]CategoryWithChildren, len(rootPtrs))
	for i, p := range rootPtrs {
		roots[i] = *p
	}
	return roots, nil
}

func (s *Service) ListAll() ([]CategoryWithChildren, error) {
	cats, err := s.repo.ListAll()
	if err != nil {
		return nil, err
	}

	// Use a pointer slice so that pointers remain valid after appends
	// (taking &roots[i] on a value slice causes stale pointers on reallocation).
	parentMap := make(map[string]*CategoryWithChildren)
	var rootPtrs []*CategoryWithChildren

	for i := range cats {
		if cats[i].ParentID == nil {
			wc := &CategoryWithChildren{Category: cats[i], Children: []Category{}}
			rootPtrs = append(rootPtrs, wc)
			parentMap[cats[i].ID] = wc
		}
	}

	for i := range cats {
		if cats[i].ParentID != nil {
			if parent, ok := parentMap[*cats[i].ParentID]; ok {
				parent.Children = append(parent.Children, cats[i])
			}
		}
	}

	roots := make([]CategoryWithChildren, len(rootPtrs))
	for i, p := range rootPtrs {
		roots[i] = *p
	}
	return roots, nil
}

func (s *Service) Create(req *CreateCategoryRequest) (*Category, error) {
	return s.repo.Create(req)
}

func (s *Service) Update(id string, req *UpdateCategoryRequest) (*Category, error) {
	return s.repo.Update(id, req)
}

func (s *Service) Delete(id string) error {
	return s.repo.SoftDelete(id)
}
