#ifndef __Navigation_hquadtree_h__
#define __Navigation_hquadtree_h__

#include "List.h"

template <typename K>
struct QuadTreeNode {
    std::vector<K>* items;
    float min[2];
    float max[2];
    QuadTreeNode<K>* NW;
    QuadTreeNode<K>* NE;
    QuadTreeNode<K>* SW;
    QuadTreeNode<K>* SE;
};

template <typename K>
class QuadTree {

public:
    QuadTree(bool (*outside)(K, float[2], float[2]), bool (*inside)(K, float[3]), float size, unsigned int capacity = 4)
    {

        this->capacity = capacity;
        this->root = new QuadTreeNode<K>();
        this->root->items = new std::vector<K>();
        this->root->NW = NULL;
        this->root->min[0] = -size;
        this->root->min[1] = -size; //min; // -16 384
        this->root->max[0] = size;
        this->root->max[1] = size;
        this->outside = outside;
        this->inside = inside;
    }

    ~QuadTree()
    {
        delete this->items;
    }

    bool Push(K key)
    {
        bool ret = this->Insert(this->root, key);
        if (ret == false) {
            printf("Insertion failed\n");
        }
        return true;
    }

    List<K>* Get(float point[3])
    {
        printf("1 --> %f %f %f\n", point[0], point[1], point[2]);
        List<K>* lst = this->Find(this->root, point);
        printf("done\n");
        return lst;
    }

    void Destroy()
    {
    }

private:
    unsigned int capacity;
    bool (*outside)(K, float[2], float[2]);
    bool (*inside)(K, float[3]);
    QuadTreeNode<K>* root;

    List<K>* Find(QuadTreeNode<K>* node, float point[3])
    {

        if (!(node->min[0] <= point[0] && node->min[1] <= point[1] && node->max[0] >= point[1] && node->max[1] >= point[1])) {
            return NULL;
        }

        List<K>* res = new List<K>();

        for (unsigned int i = 0; i < node->items->size(); i++)
            if (inside(node->items->at(i), point))
                res->Append(node->items->at(i));
        if (res->Size() == 0) {
            printf("not found\n");
            for (unsigned int i = 0; i < node->items->size(); i++)
                res->Append(node->items->at(i));
        }

        if (this->IsSubdivided(node)) {
            res->Merge(this->Find(node->NW, point));
            res->Merge(this->Find(node->NE, point));
            res->Merge(this->Find(node->SW, point));
            res->Merge(this->Find(node->SE, point));
        }
        return res;
    }

    bool Insert(QuadTreeNode<K>* node, K key)
    {
        if (!IsFullyContained(node, key))
            return false;

        if (this->IsFull(node) == false) {
            node->items->push_back(key);
            return true;
        }

        if (!this->IsSubdivided(node))
            node = this->Subdivide(node);

        if (this->Insert(node->NW, key))
            return true;
        if (this->Insert(node->NE, key))
            return true;
        if (this->Insert(node->SW, key))
            return true;
        if (this->Insert(node->SE, key))
            return true;

        node->items->push_back(key);

        return true;
    }
    bool IsSubdivided(QuadTreeNode<K>* node)
    {
        return (node->NW != NULL);
    }
    bool IsFull(QuadTreeNode<K>* node)
    {
        return (node->items->size() >= this->capacity);
    }
    bool IsFullyContained(QuadTreeNode<K>* node, K key)
    {
        return this->outside(key, node->min, node->max);
    }
    QuadTreeNode<K>* Subdivide(QuadTreeNode<K>* node)
    {
        node->NW = new QuadTreeNode<K>();
        node->NE = new QuadTreeNode<K>();
        node->SW = new QuadTreeNode<K>();
        node->SE = new QuadTreeNode<K>();

        refresh(node, node->NW, node->NE, node->SW, node->SE);

        std::vector<K>* tmp = new std::vector<K>();
        for (unsigned int i = 0; i < node->items->size(); i++)
            tmp->push_back(node->items->at(i));

        node->items->clear();

        for (unsigned int i = 0; i < tmp->size(); i++)
            this->Insert(node, tmp->at(i));

        delete tmp;
        return node;
    }
    void refresh(QuadTreeNode<K>* parent, QuadTreeNode<K>* NW, QuadTreeNode<K>* NE, QuadTreeNode<K>* SW, QuadTreeNode<K>* SE)
    {
        float center[2];
        center[0] = (parent->min[0] + parent->max[0]) / 2.0;
        center[1] = (parent->min[0] + parent->max[1]) / 2.0;

        NW->items = new std::vector<K>(0);
        NE->items = new std::vector<K>(0);
        SW->items = new std::vector<K>(0);
        SE->items = new std::vector<K>(0);
        NW->NW = NULL;
        NE->NW = NULL;
        SW->NW = NULL;
        SE->NW = NULL;

        NW->min[0] = parent->min[0]; // -16
        NW->min[1] = parent->min[1]; // -16
        NW->max[0] = center[0]; // 0
        NW->max[1] = center[1]; // 0

        NE->min[0] = center[0]; // 0
        NE->min[1] = parent->min[1]; // -16
        NE->max[0] = parent->max[0]; // 16
        NE->max[1] = center[1]; // 0

        SW->min[0] = parent->min[0]; // -16
        SW->min[1] = center[1]; // 0
        SW->max[0] = center[0]; // 0
        SW->max[1] = parent->max[1]; // 16

        SE->min[0] = center[0]; // 0
        SE->min[1] = center[1]; // 0
        SE->max[0] = parent->max[0]; // 16
        SE->max[1] = parent->max[1]; // 16
    }
};

#endif